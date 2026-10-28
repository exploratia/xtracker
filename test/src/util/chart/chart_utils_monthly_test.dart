import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/series/data/monthly/monthly_value.dart';
import 'package:xtracker/src/model/series/seriesItem/calculated/calculation_container.dart';
import 'package:xtracker/src/model/series/seriesItem/calculated/calculation_item_series_value.dart';
import 'package:xtracker/src/model/series/seriesItem/calculated/calculation_operator.dart';
import 'package:xtracker/src/model/series/seriesItem/series_item.dart';
import 'package:xtracker/src/model/series/series_def.dart';
import 'package:xtracker/src/model/series/series_type.dart';
import 'package:xtracker/src/model/series/series_view_meta_data.dart';
import 'package:xtracker/src/util/chart/chart_utils_monthly.dart';
import 'package:xtracker/src/widgets/controls/chart/legend_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('limits a later calculated monthly column to years with valid values', () {
    final items = [_item('first'), _item('second'), _item('deltaFirst', calculation: _delta('first')), _item('deltaSecond', calculation: _delta('second'))];
    final meta = _meta(items);
    final rows = <MonthlyValue>[];
    var previous = <String, double>{};
    for (var month = 1; month <= 58; month++) {
      final input = <String, double>{'first': month * 10.0, if (month >= 52) 'second': (month - 51) * (month - 51) * 1.0};
      final values = {...input};
      for (final item in items.where((item) => item.isCalculated)) {
        values[item.siid] = item.calculationContainer!.calculate(input, previous);
      }
      rows.add(MonthlyValue('row$month', DateTime(2022, month), values, null));
      previous = input;
    }

    final parameters = ChartUtilsMonthly.buildDataProviderPerParameter(meta, rows);
    final calculated = parameters[3].data;
    expect(parameters[0].data, hasLength(58));
    expect(parameters[1].data, hasLength(7));
    expect(calculated.map((value) => value.dateTime), [for (var month = 5; month <= 10; month++) DateTime(2026, month)]);
    expect(calculated.map((value) => value.value), [3, 5, 7, 9, 11, 13]);

    final chart = ChartUtilsMonthly.buildLineChartDataMonthly(meta, items[3], calculated, ThemeData(), null);
    expect(chart.lineBarsData, hasLength(1));
    expect(chart.lineBarsData.single.spots.every((spot) => spot.y.isFinite), isTrue);
    final legend = ChartUtilsMonthly.buildMonthlyChartLegend(items[3], calculated) as Wrap;
    expect(legend.children.cast<LegendItem>().map((item) => item.label), ['26']);
    final bar = chart.lineBarsData.single;
    final tooltip = chart.lineTouchData.touchTooltipData.getTooltipItems([LineBarSpot(bar, 0, bar.spots.first)]).single!;
    expect(tooltip.children!.single.toPlainText(), contains('(2026)'));
  });

  for (final compressed in [false, true]) {
    group(compressed ? 'yearly data' : 'monthly data', () {
      test('skips missing and non-finite values while preserving zero', () {
        final meta = _meta([_item('value')], compressed: compressed);
        final rows = [
          _row(2022, 1, double.nan),
          _row(2023, 1, double.infinity),
          _row(2024, 1, double.negativeInfinity),
          _row(2025, 1, null),
          _row(2026, 1, 0),
          _row(2026, 2, 8),
          _row(2026, 3, double.nan),
        ];
        final data = ChartUtilsMonthly.buildDataProviderPerParameter(meta, rows).single.data;
        expect(data.map((value) => value.value), compressed ? [8] : [0, 8]);
        expect(data.every((value) => value.dateTime.year == 2026), isTrue);
      });

      test('keeps a column empty when no values can be calculated', () {
        final data = ChartUtilsMonthly.buildDataProviderPerParameter(
          _meta([_item('value')], compressed: compressed),
          [_row(2022, 1, double.nan), _row(2023, 1, double.infinity), _row(2026, 1, null)],
        ).single.data;
        expect(data, isEmpty);
      });

      test('ignores invalid values before calculating signed deltas', () {
        final meta = _meta([_item('value', useDelta: true)], compressed: compressed);
        final rows = compressed
            ? [_row(2022, 12, 100), _row(2023, 1, double.nan), _row(2023, 6, 140), _row(2023, 12, double.infinity), _row(2024, 1, 5), _row(2024, 12, 15)]
            : [_row(2026, 1, 100), _row(2026, 2, double.nan), _row(2026, 3, 140), _row(2026, 4, double.infinity), _row(2026, 5, 5), _row(2026, 6, 15)];
        final data = ChartUtilsMonthly.buildDataProviderPerParameter(meta, rows).single.data;
        expect(data.map((value) => value.value), compressed ? [40, -125] : [40, -135, 10]);
      });
    });
  }

  test('connects valid months across missing rows and missing column values', () {
    final item = _item('value');
    final meta = _meta([item]);
    final data = ChartUtilsMonthly.buildDataProviderPerParameter(
      meta,
      [_row(2026, 1, 10), _row(2026, 2, null), _row(2026, 3, double.nan), _row(2026, 5, 20)],
    ).single.data;
    final chart = ChartUtilsMonthly.buildLineChartDataMonthly(meta, item, data, ThemeData(), null);
    expect(chart.lineBarsData.single.spots, [const FlSpot(1, 10), const FlSpot(5, 20)]);
  });

  test('uses actual years and curve colors in tooltips when a year is absent', () {
    final item = _item('value');
    final meta = _meta([item]);
    final data = ChartUtilsMonthly.buildDataProviderPerParameter(
      meta,
      [_row(2022, 1, 10), _row(2023, 1, double.nan), _row(2024, 1, 20)],
    ).single.data;
    final chart = ChartUtilsMonthly.buildLineChartDataMonthly(meta, item, data, ThemeData(), null);
    expect(chart.lineBarsData, hasLength(2));
    final bar = chart.lineBarsData[1];
    final tooltip = chart.lineTouchData.touchTooltipData.getTooltipItems([LineBarSpot(bar, 1, bar.spots.single)]).single!;
    expect(tooltip.children!.single.toPlainText(), contains('(2024)'));
    expect(tooltip.textStyle.color, bar.color);
  });
}

SeriesViewMetaData _meta(List<SeriesItem> items, {bool compressed = false}) => SeriesViewMetaData(
  seriesDef: SeriesDef(uuid: 'monthly', seriesType: SeriesType.monthly, seriesItems: items),
)..showCompressed = compressed;

SeriesItem _item(String id, {CalculationContainer? calculation, bool useDelta = false}) =>
    SeriesItem(id, id, 'kWh', Colors.blue, false, false, null, useDelta, calculation);

MonthlyValue _row(int year, int month, double? value) => MonthlyValue('$year-$month', DateTime(year, month), {'value': ?value}, null);

CalculationContainer _delta(String source) => CalculationContainer(
  sourceSiid: source,
  usePreviousInput: false,
  calculationItems: [
    CalculationItemSeriesValue(
      operator: CalculationOperator.subtract,
      calculationContainer: CalculationContainer(sourceSiid: source, usePreviousInput: true, calculationItems: []),
    ),
  ],
);
