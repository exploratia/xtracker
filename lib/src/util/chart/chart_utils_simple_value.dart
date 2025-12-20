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
  static LineChartData buildLineChartData(
    SeriesViewMetaData seriesViewMetaData,
    List<TimedValue> simpleValues,
    ThemeData themeData,
    String Function(DateTime dateTime) dateFormatter,
    Function(FlTouchEvent, LineTouchResponse?)? touchCallback, {
    Color? lineColor,
    bool showDots = true,
    bool isCurved = false,
    double lineWidth = 5,
    bool showSpotLine = false,
    bool showAreaBelowLine = false,
    bool showToucheLine = false,
    int fractionDigits = 0,
  }) {
    var lineCol = lineColor ?? seriesViewMetaData.seriesDef.color;

    List<LineChartBarData> lineBarsData = [];

    ChartMetaData chartMetaData = ChartMetaData();
    chartMetaData.showDots = showDots;

    List<FlSpot> values = [];

    for (var item in simpleValues) {
      var value = item.value;
      var t = item.dateTime.millisecondsSinceEpoch;

      chartMetaData.evaluateMetaData(t, [value]);

      values.add(FlSpot(t.toDouble(), value.toDouble()));
    }

    lineBarsData.add(
      LineChartBarData(
        spots: values,
        isCurved: isCurved,
        preventCurveOverShooting: true,
        barWidth: lineWidth,
        color: lineCol,
        dotData: ChartUtils.createDotData(chartMetaData),
        isStrokeCapRound: true,
        // dashArray: [5, 5],
        belowBarData: BarAreaData(
          show: showAreaBelowLine || showSpotLine,
          color: showAreaBelowLine ? null : Colors.transparent,
          gradient: showAreaBelowLine
              ? ChartUtils.createTopToBottomGradient([
                  lineCol,
                  Colors.transparent,
                ])
              : null,
          spotsLine: BarAreaSpotsLine(
            show: showSpotLine,
            flLineStyle: FlLine(
              // color: lineCol,
              strokeWidth: 5,
              gradient: ChartUtils.createTopToBottomGradient([
                ColorUtils.gradientColor(lineCol),
                lineCol,
              ]),
            ),
          ),
        ),
      ),
    );

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
        fractionDigits: fractionDigits,
        showToucheLine: showToucheLine,
        themeData: themeData,
        touchCallback: touchCallback,
        provideTooltipTextColor: (x, y, barIdx) => lineCol,
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

class TimedValue {
  double value = 0;
  final DateTime dateTime;

  TimedValue(this.dateTime);

  TimedValue.value(this.dateTime, this.value);

  void increment() {
    value++;
  }

  void add(double? val) => value += (val ?? 0);

  void set(double? val) => value = (val ?? 0);

  /// only calculates delta if value is bigger then prevValue.
  /// otherwise it's counted as a reset (e.g. exchange of water meter)
  void buildDelta(double prevValue) {
    if (value > prevValue) {
      value = value - prevValue;
    }
  }

  @override
  String toString() {
    return 'SimpleValue{value: $value, dateTime: $dateTime}';
  }
}
