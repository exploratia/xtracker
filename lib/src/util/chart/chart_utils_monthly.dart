import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/chart/chart_meta_data.dart';
import '../../model/series/data/monthly/monthly_value.dart';
import '../../model/series/seriesItem/series_item.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_view_meta_data.dart';
import '../../widgets/controls/chart/title_bottom_axis.dart';
import '../date_time_utils.dart';
import '../ex.dart';
import '../media_query_utils.dart';
import 'chart_utils.dart';
import 'chart_utils_simple_value.dart';

class ChartUtilsMonthly {
  static List<ParameterChartData> buildDataProviderPerParameter(SeriesViewMetaData seriesViewMetaData, List<MonthlyValue> seriesData) {
    Map<String, List<TimedValue>> siid2values = {};
    Map<String, bool> siid2useDelta = {};
    for (var si in seriesViewMetaData.seriesDef.seriesItems) {
      siid2values[si.siid] = [];
      siid2useDelta[si.siid] = si.useDeltaInChart;
    }

    var siids = siid2values.keys;
    Map<String, double> prevValues = {};

    if (seriesViewMetaData.showCompressed) {
      // compress yearly
      Map<String, TimedValue> siid2actValue = {};

      for (final dataItem in seriesData) {
        var ts = DateTimeUtils.firstDayOfYear(dataItem.dateTime);
        // check duplicate timestamps for monthly
        for (final siid in siids) {
          final v = dataItem.values[siid];
          if (v != null) {
            var actValue = siid2actValue[siid];
            if (actValue == null) {
              siid2actValue[siid] = TimedValue.value(ts, v);
            } else {
              // same timestamp -> update
              if (actValue.dateTime == ts) {
                actValue.add(v);
              }
              // otherwise store so far and create new
              else {
                // calc delta?
                if (siid2useDelta[siid] ?? false) {
                  var prevValue = prevValues[siid] ?? 0;
                  prevValues[siid] = actValue.value;
                  actValue.buildDelta(prevValue);
                }

                siid2values[siid]!.add(actValue);
                siid2actValue[siid] = TimedValue.value(ts, v);
              }
            }
          }
        }
      }

      // add not yet added to lists
      for (var entry in siid2actValue.entries) {
        var siid = entry.key;
        // calc delta?
        if (siid2useDelta[siid] ?? false) {
          var prevValue = prevValues[siid] ?? 0;
          entry.value.buildDelta(prevValue);
        }

        siid2values[siid]!.add(entry.value);
      }
    } else {
      DateTime? prevTimestamp;
      for (final dataItem in seriesData) {
        // check duplicate timestamps for monthly
        if (dataItem.dateTime == prevTimestamp) {
          throw Ex(
            "Found duplicate timestamp '$prevTimestamp' in monthly data in series '${seriesViewMetaData.seriesDef.name}'!",
            localizedMessage: LocaleKeys.seriesData_monthly_msg_duplicateTimestamp.tr(args: [DateTimeUtils.formatMonthYear(dataItem.dateTime)]),
          );
        }
        prevTimestamp = dataItem.dateTime;
        for (final siid in siids) {
          final v = dataItem.values[siid];
          if (v != null) {
            var prevValue = prevValues[siid] ?? 0;
            var val = (siid2useDelta[siid] ?? false) ? v - prevValue : v;
            siid2values[siid]!.add(
              TimedValue.value(dataItem.dateTime, val),
            );
            prevValues[siid] = v;
          }
        }
      }
    }

    List<ParameterChartData> result = [];
    for (var seriesItem in seriesViewMetaData.seriesDef.seriesItems.where((si) => !si.hideInChart)) {
      result.add(ParameterChartData(seriesDef: seriesViewMetaData.seriesDef, seriesItem: seriesItem, data: siid2values[seriesItem.siid]!));
    }
    return result;
  }

  static LineChartData buildLineChartDataMonthly(
    SeriesViewMetaData seriesViewMetaData,
    SeriesItem seriesItem,
    List<TimedValue> simpleValues,
    ThemeData themeData,
    String Function(DateTime dateTime) dateFormatter,
    Function(FlTouchEvent, LineTouchResponse?)? touchCallback,
  ) {
    List<LineChartBarData> lineBarsData = [];

    ChartMetaData chartMetaData = ChartMetaData();
    chartMetaData.showDots = false;

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
        isCurved: true,
        preventCurveOverShooting: true,
        barWidth: 2,
        color: seriesItem.color,
        dotData: ChartUtils.createDotData(chartMetaData),
        isStrokeCapRound: true,
        // dashArray: [5, 5],
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
        fractionDigits: 0,
        showToucheLine: true,
        themeData: themeData,
        touchCallback: touchCallback,
        provideTooltipTextColor: (x, y, barIdx) => seriesItem.color,
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

  static LineChartData buildLineChartDataYearly(
    SeriesViewMetaData seriesViewMetaData,
    SeriesItem seriesItem,
    List<TimedValue> simpleValues,
    ThemeData themeData,
    String Function(DateTime dateTime) dateFormatter,
    Function(FlTouchEvent, LineTouchResponse?)? touchCallback,
  ) {
    List<LineChartBarData> lineBarsData = [];

    ChartMetaData chartMetaData = ChartMetaData();
    chartMetaData.showDots = true;

    List<FlSpot> values = [];

    for (var item in simpleValues) {
      var value = item.value;
      var t = item.dateTime.year % 1000;

      chartMetaData.evaluateMetaData(t, [value]);

      values.add(FlSpot(t.toDouble(), value.toDouble()));
    }

    lineBarsData.add(
      LineChartBarData(
        spots: values,
        isCurved: true,
        preventCurveOverShooting: true,
        barWidth: 2,
        color: seriesItem.color,
        dotData: ChartUtils.createDotData(chartMetaData),
        isStrokeCapRound: true,
        // dashArray: [5, 5],
        belowBarData: BarAreaData(show: true, gradient: ChartUtils.createTopToBottomGradient([seriesItem.color.withAlpha(128), seriesItem.color.withAlpha(0)])),
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
        fractionDigits: 0,
        showToucheLine: true,
        themeData: themeData,
        touchCallback: touchCallback,
        provideTooltipTextColor: (x, y, barIdx) => seriesItem.color,
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
            maxIncluded: false,
            minIncluded: false,
            // https://www.reddit.com/r/flutterhelp/comments/rhb7iu/fl_chart_set_time_series_interval_in_linechart/?rdt=36768
            // interval: (chartMetaData.xMax - chartMetaData.xMin),
            interval: 1,
            getTitlesWidget: (value, meta) {
              return TitleBottomAxis(
                alignment: Alignment.topCenter,
                value: value,
                height: bottomTitlesHeight,
                maxWidth: bottomTitlesMaxWidth,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ParameterChartData {
  final SeriesDef seriesDef;
  final SeriesItem seriesItem;
  final List<TimedValue> data;

  ParameterChartData({required this.seriesDef, required this.seriesItem, required this.data});
}
