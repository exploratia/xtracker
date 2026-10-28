import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/series/data/custom/custom_value.dart';
import 'package:xtracker/src/model/series/data/monthly/monthly_value.dart';
import 'package:xtracker/src/model/series/seriesItem/series_item.dart';
import 'package:xtracker/src/model/series/series_def.dart';
import 'package:xtracker/src/model/series/series_type.dart';
import 'package:xtracker/src/model/series/series_view_meta_data.dart';
import 'package:xtracker/src/util/chart/chart_utils_custom.dart';
import 'package:xtracker/src/util/chart/chart_utils_monthly.dart';
import 'package:xtracker/src/util/chart/chart_utils_simple_value.dart';
import 'package:xtracker/src/util/json_reader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists filtering per column and retains it through copy and edit operations', () {
    final item = _item('electricity', filter: true);
    expect(SeriesItem.fromJson(JsonReader(item.toJson())).filterDeltaOutliersInChart, isTrue);
    expect(item.clone().filterDeltaOutliersInChart, isTrue);
    expect(item.withTableSettings(true, 80).filterDeltaOutliersInChart, isTrue);
    expect(item.withChartSettings(false, false).filterDeltaOutliersInChart, isTrue);
    expect(item.withChartSettings(false, true, filterDeltaOutliersInChart: false).filterDeltaOutliersInChart, isFalse);
    final legacy = item.toJson()..remove('filterDeltaOutliersInChart');
    expect(SeriesItem.fromJson(JsonReader(legacy)).filterDeltaOutliersInChart, isFalse);
  });

  test('filters one monthly column independently and never filters absolute values', () {
    final items = [_item('electricity', filter: true), _item('water'), _item('absolute', filter: true, delta: false)];
    final meta = _meta(items);
    final rows = _rows();
    final parameters = ChartUtilsMonthly.buildDataProviderPerParameter(meta, rows);
    expect(parameters[0].data[2].isGap, isTrue);
    expect(parameters[0].data[3].value, 250);
    expect(parameters[1].data.map((point) => point.value), List.filled(7, 10));
    expect(parameters[2].data.map((point) => point.value), rows.map((row) => row.values['absolute']));
    expect(rows[3].values['electricity'], 20);
    final chart = ChartUtilsMonthly.buildLineChartDataMonthly(meta, items[0], parameters[0].data, ThemeData(), null);
    expect(chart.lineBarsData.single.spots[2], FlSpot.nullSpot);
    expect(chart.minY, greaterThanOrEqualTo(0));
    expect(chart.maxY, lessThan(300));
  });

  test('custom charts allow signed deltas and render filtered transitions as gaps', () {
    final item = _item('electricity', filter: true);
    final meta = _meta([item], type: SeriesType.custom);
    final data = ChartUtilsCustom.buildDataProviderPerParameter(
      meta,
      _rows().map((row) => CustomValue(row.uuid, row.dateTime, row.values, null)).toList(),
    ).single.data;
    final chart = ChartUtilsSimpleValue.buildLineChartData(meta, data, ThemeData(), (date) => '$date', null);
    expect(data[2].isGap, isTrue);
    expect(data[3].value, 250);
    expect(chart.lineBarsData.single.spots[2], FlSpot.nullSpot);
    expect(chart.maxY, lessThan(300));

    final signed = ChartUtilsCustom.buildDataProviderPerParameter(meta, [
      CustomValue('a', DateTime(2026, 1), {'electricity': 80}, null),
      CustomValue('b', DateTime(2026, 2), {'electricity': 79}, null),
    ]).single.data;
    expect(signed.single.value, -1);
  });

  test('filters before annual aggregation and resumes after an incomplete year', () {
    final item = _item('electricity', filter: true);
    final meta = _meta([item])..showCompressed = true;
    final rows = [
      MonthlyValue('baseline', DateTime(2024, 12), {'electricity': 12000}, null),
      ..._rows(),
      MonthlyValue('nextYear', DateTime(2027, 1), {'electricity': 1270}, null),
      MonthlyValue('nextYearEnd', DateTime(2027, 12), {'electricity': 1520}, null),
    ];
    final data = ChartUtilsMonthly.buildDataProviderPerParameter(meta, rows).single.data;
    expect(data.map((point) => point.dateTime.year), [2026, 2027]);
    expect(data.first.isGap, isTrue);
    expect(data.last.value, 500);
    final chart = ChartUtilsMonthly.buildLineChartDataYearly(meta, item, data, ThemeData(), null);
    expect(chart.lineBarsData.single.spots.first, FlSpot.nullSpot);
    expect(chart.minY.isFinite && chart.maxY.isFinite, isTrue);
  });

  testWidgets('renders monthly and yearly gaps including an entirely missing annual total', (tester) async {
    final item = _item('electricity', filter: true);
    final meta = _meta([item]);
    final data = ChartUtilsMonthly.buildDataProviderPerParameter(meta, _rows()).single.data;
    final charts = [
      ChartUtilsMonthly.buildLineChartDataMonthly(meta, item, data, ThemeData(), null),
      ChartUtilsMonthly.buildLineChartDataYearly(meta, item, [TimedValue.gap(DateTime(2026))], ThemeData(), null),
      ChartUtilsSimpleValue.buildLineChartData(meta, data, ThemeData(), (date) => '$date', null),
    ];
    for (final chart in charts) {
      expect(chart.minY.isFinite && chart.maxY.isFinite, isTrue);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SizedBox(height: 300, child: LineChart(chart))),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}

SeriesItem _item(String id, {bool filter = false, bool delta = true}) =>
    SeriesItem(id, id, 'kWh', Colors.blue, false, false, null, delta, null, filterDeltaOutliersInChart: filter);

SeriesViewMetaData _meta(List<SeriesItem> items, {SeriesType type = SeriesType.monthly}) => SeriesViewMetaData(
  seriesDef: SeriesDef(uuid: 'series', seriesType: type, seriesItems: items),
);

List<MonthlyValue> _rows() {
  const electricity = [12000.0, 12250.0, 12500.0, 20.0, 270.0, 520.0, 770.0, 1020.0];
  return [
    for (var i = 0; i < electricity.length; i++)
      MonthlyValue('row$i', DateTime(2026, i + 1), {'electricity': electricity[i], 'water': 100 + i * 10, 'absolute': electricity[i]}, null),
  ];
}
