import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../model/chart/chart_meta_data.dart';
import '../../model/series/data/daily_check/daily_check_value.dart';
import '../../model/series/data/series_data.dart';
import '../../model/series/series_view_meta_data.dart';
import '../color_utils.dart';
import '../date_time_utils.dart';
import 'chart_utils.dart';

class ChartUtilsDailyCheck {
  static LineChartData buildLineChartData(SeriesViewMetaData seriesViewMetaData, SeriesData<DailyCheckValue> seriesData, List<CombinedValue> combinedSeriesData,
      ThemeData themeData, Function(FlTouchEvent, LineTouchResponse?)? touchCallback) {
    List<LineChartBarData> lineBarsData = [];

    ChartMetaData chartMetaData = ChartMetaData();
    chartMetaData.showDots = true;

    List<FlSpot> values = [];

    for (var item in combinedSeriesData) {
      var value = item.value;
      var t = item.dateTime.millisecondsSinceEpoch;

      chartMetaData.evaluateMetaData(t, [value]);

      values.add(FlSpot(t.toDouble(), value.toDouble()));
    }

    lineBarsData.add(LineChartBarData(
      spots: values,
      isCurved: false,
      preventCurveOverShooting: true,
      barWidth: 0,
      gradient: ChartUtils.createTopToBottomGradient([seriesViewMetaData.seriesDef.color, ColorUtils.hue(seriesViewMetaData.seriesDef.color)]),
      dotData: ChartUtils.createDotData(chartMetaData),
      isStrokeCapRound: true,
      // dashArray: [5, 5],
    ));

    chartMetaData.calcPadding();

    final String Function(DateTime dateTime) dateFormatter = seriesViewMetaData.showYearly ? DateTimeUtils.formateYear : DateTimeUtils.formateMonthYear;

    return LineChartData(
      minY: chartMetaData.yMinPadded,
      maxY: chartMetaData.yMaxPadded,
      minX: chartMetaData.xMinPadded,
      maxX: chartMetaData.xMaxPadded,
      clipData: const FlClipData.all(),
      lineBarsData: lineBarsData,
      borderData: ChartUtils.borderData,
      gridData: ChartUtils.noGridData,
      lineTouchData: ChartUtils.createLineTouchData(
        fractionDigits: 0,
        themeData: themeData,
        touchCallback: touchCallback,
        provideTooltipTextColor: (x, y, barIdx) => seriesViewMetaData.seriesDef.color,
      ),
      titlesData: FlTitlesData(
        rightTitles: ChartUtils.axisTitlesNoTitles,
        topTitles: ChartUtils.axisTitlesNoTitles,
        leftTitles: const AxisTitles(
          drawBelowEverything: true,
          sideTitles: SideTitles(
            showTitles: true,
            maxIncluded: false,
            minIncluded: false,
            reservedSize: 40,
            getTitlesWidget: ChartUtils.createTitlesLeft,
          ),
        ),
        bottomTitles: AxisTitles(
          drawBelowEverything: true,
          sideTitles: SideTitles(
            showTitles: true,
            maxIncluded: true,
            minIncluded: true,
            // https://www.reddit.com/r/flutterhelp/comments/rhb7iu/fl_chart_set_time_series_interval_in_linechart/?rdt=36768
            // interval: (chartMetaData.xMax - chartMetaData.xMin),
            interval: math.max(1, values.last.x - values.first.x),
            getTitlesWidget: (value, meta) {
              if (value == meta.min) {
                // use chartMetaData min/max - not the value which has padding!
                return TitlesWidgetBottomAxis(alignment: Alignment.topLeft, value: chartMetaData.xMin, dateFormatter: dateFormatter);
              } else if (value == meta.max) {
                return TitlesWidgetBottomAxis(alignment: Alignment.topRight, value: chartMetaData.xMax, dateFormatter: dateFormatter);
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class TitlesWidgetBottomAxis extends StatelessWidget {
  const TitlesWidgetBottomAxis({
    super.key,
    required this.alignment,
    required this.value,
    required this.dateFormatter,
  });

  final Alignment alignment;
  final double value;
  final String Function(DateTime dateTime) dateFormatter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0,
      // height: 22,
      child: OverflowBox(
        alignment: alignment,
        maxWidth: 180,
        // maxHeight: 22,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(dateFormatter(DateTime.fromMillisecondsSinceEpoch(value.truncate()))),
        ),
      ),
    );
  }
}

class CombinedValue {
  double value = 1;
  final DateTime dateTime;

  CombinedValue(this.dateTime);

  void increment() {
    value++;
  }
}
