import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../model/chart/chart_meta_data.dart';
import '../../model/series/series_view_meta_data.dart';
import '../../widgets/controls/chart/title_bottom_axis.dart';
import '../color_utils.dart';
import '../media_query_utils.dart';
import 'chart_utils.dart';

class ChartUtilsSimpleValue {
  static LineChartData buildLineChartData(SeriesViewMetaData seriesViewMetaData, List<SimpleValue> simpleValues, ThemeData themeData,
      String Function(DateTime dateTime) dateFormatter, Function(FlTouchEvent, LineTouchResponse?)? touchCallback) {
    List<LineChartBarData> lineBarsData = [];

    ChartMetaData chartMetaData = ChartMetaData();
    chartMetaData.showDots = true;

    List<FlSpot> values = [];

    for (var item in simpleValues) {
      var value = item.value;
      var t = item.dateTime.millisecondsSinceEpoch;

      chartMetaData.evaluateMetaData(t, [value]);

      values.add(FlSpot(t.toDouble(), value.toDouble()));
    }

    lineBarsData.add(LineChartBarData(
        spots: values,
        isCurved: false,
        preventCurveOverShooting: true,
        // hide bar:
        barWidth: 0,
        color: seriesViewMetaData.seriesDef.color,
        dotData: ChartUtils.createDotData(chartMetaData),
        isStrokeCapRound: true,
        // dashArray: [5, 5],
        belowBarData: BarAreaData(
          show: true,
          color: Colors.transparent,
          spotsLine: BarAreaSpotsLine(
            show: true,
            flLineStyle: FlLine(
              // color: seriesViewMetaData.seriesDef.color,
              strokeWidth: 5,
              gradient: ChartUtils.createTopToBottomGradient([
                ColorUtils.gradientColor(seriesViewMetaData.seriesDef.color),
                seriesViewMetaData.seriesDef.color,
              ]),
            ),
          ),
        )));

    chartMetaData.calcPadding();

    var maxLen = 40;
    var leftTitlesWidth = maxLen * MediaQueryUtils.textScaleFactor;
    var bottomTitlesHeight = 22 * MediaQueryUtils.textScaleFactor;
    var bottomTitlesMaxWidth = 180 * MediaQueryUtils.textScaleFactor;

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
        showToucheLine: false,
        themeData: themeData,
        touchCallback: touchCallback,
        provideTooltipTextColor: (x, y, barIdx) => seriesViewMetaData.seriesDef.color,
      ),
      titlesData: FlTitlesData(
        rightTitles: ChartUtils.axisTitlesNoTitles,
        topTitles: ChartUtils.axisTitlesNoTitles,
        leftTitles: AxisTitles(
          drawBelowEverything: true,
          sideTitles: SideTitles(
            showTitles: true,
            maxIncluded: false,
            minIncluded: false,
            reservedSize: leftTitlesWidth,
            getTitlesWidget: ChartUtils.createTitlesLeft,
          ),
        ),
        bottomTitles: AxisTitles(
          drawBelowEverything: true,
          sideTitles: SideTitles(
            reservedSize: bottomTitlesHeight,
            showTitles: true,
            maxIncluded: true,
            minIncluded: true,
            // https://www.reddit.com/r/flutterhelp/comments/rhb7iu/fl_chart_set_time_series_interval_in_linechart/?rdt=36768
            // interval: (chartMetaData.xMax - chartMetaData.xMin),
            interval: math.max(1, values.last.x - values.first.x),
            getTitlesWidget: (value, meta) {
              if (value == meta.min) {
                // use chartMetaData min/max - not the value which has padding!
                return TitleBottomAxis(
                  alignment: Alignment.topLeft,
                  value: chartMetaData.xMin,
                  dateFormatter: dateFormatter,
                  height: bottomTitlesHeight,
                  maxWidth: bottomTitlesMaxWidth,
                );
              } else if (value == meta.max) {
                return TitleBottomAxis(
                  alignment: Alignment.topRight,
                  value: chartMetaData.xMax,
                  dateFormatter: dateFormatter,
                  height: bottomTitlesHeight,
                  maxWidth: bottomTitlesMaxWidth,
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}

class SimpleValue {
  double value = 1;
  final DateTime dateTime;

  SimpleValue(this.dateTime);

  void increment() {
    value++;
  }
}
