import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/chart/chart_meta_data.dart';
import '../../model/series/data/monthly/monthly_value.dart';
import '../../model/series/seriesItem/series_item.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_view_meta_data.dart';
import '../../widgets/controls/chart/legend_item.dart';
import '../../widgets/controls/chart/title_bottom_axis.dart';
import '../color_utils.dart';
import '../date_time_utils.dart';
import '../ex.dart';
import '../media_query_utils.dart';
import '../theme_utils.dart';
import 'chart_utils.dart';
import 'chart_utils_simple_value.dart';

class ChartUtilsMonthly {
  static List<ParameterChartData> buildDataProviderPerParameter(SeriesViewMetaData seriesViewMetaData, List<MonthlyValue> seriesData) {
    Map<String, List<TimedValue>> siid2values = {};
    Map<String, bool> siid2useDelta = {};

    // first check if delta calculation is possible
    // if a parameter has no value... this check is not enough :/
    bool isDeltaPossible = false;
    if (seriesData.length > 1) {
      if (seriesViewMetaData.showCompressed) {
        // compressed we need first and last to be different years
        isDeltaPossible = seriesData.first.dateTime.year != seriesData.last.dateTime.year;
      } else {
        // uncompressed we need at least 2 values for one delta
        isDeltaPossible = true;
      }
    }

    for (var si in seriesViewMetaData.seriesDef.seriesItems.where((si) => !si.hideInChart)) {
      siid2values[si.siid] = [];
      siid2useDelta[si.siid] = isDeltaPossible && si.useDeltaInChart;
    }

    var siids = siid2values.keys;

    if (seriesViewMetaData.showCompressed) {
      // compress yearly
      for (final siid in siids) {
        TimedValue? actValue;
        double prevValue = 0;
        double resetValue = 0;
        for (final dataItem in seriesData) {
          final v = dataItem.values[siid];
          if (v != null) {
            var ts = DateTimeUtils.firstDayOfYear(dataItem.dateTime);
            if (actValue == null) {
              actValue = TimedValue.value(ts, v);
            } else {
              // same timestamp -> update
              if (actValue.dateTime == ts) {
                // in case of delta check if we got a reset value (value < prevValue)
                // save the prev value in reset to be able to add it at the end
                if (siid2useDelta[siid] ?? false) {
                  if (v < actValue.value) {
                    resetValue += actValue.value;
                  }
                }
                actValue.set(v);
              }
              // otherwise store so far and create new
              else {
                // calc delta?
                if (siid2useDelta[siid] ?? false) {
                  // get prevValue for delta calculation
                  var prevVal = prevValue;
                  // first store value as prevValue (to have the correct value for the next year).
                  prevValue = actValue.value;
                  // afterwards add a possible resetValue
                  actValue.add(resetValue);
                  // build delta
                  actValue.buildDelta(prevVal);
                }

                siid2values[siid]!.add(actValue);
                actValue = TimedValue.value(ts, v);
                resetValue = 0;
              }
            }
          }
        }
        // add not yet added to lists
        if (actValue != null) {
          // calc delta?
          if (siid2useDelta[siid] ?? false) {
            actValue.add(resetValue);
            actValue.buildDelta(prevValue);
          }

          siid2values[siid]!.add(actValue);
        }
      }
    } else {
      // uncompressed = monthly
      DateTime? prevTimestamp;
      for (final siid in siids) {
        double prevValue = 0;
        for (final dataItem in seriesData) {
          // check duplicate timestamps for monthly
          if (dataItem.dateTime == prevTimestamp) {
            throw Ex(
              "Found duplicate timestamp '$prevTimestamp' in monthly data in series '${seriesViewMetaData.seriesDef.name}'!",
              localizedMessage: LocaleKeys.seriesData_monthly_msg_duplicateTimestamp.tr(args: [DateTimeUtils.formatMonthYear(dataItem.dateTime)]),
            );
          }
          prevTimestamp = dataItem.dateTime;
          final v = dataItem.values[siid];
          if (v != null) {
            var val = v;
            if (siid2useDelta[siid] ?? false) {
              val = v - prevValue;
              // if val < 0 we had a reset...
              if (val < 0) val = v;
              prevValue = v;
            }

            siid2values[siid]!.add(
              TimedValue.value(dataItem.dateTime, val),
            );
          }
        }
      }
    }

    List<ParameterChartData> result = [];
    for (var seriesItem in seriesViewMetaData.seriesDef.seriesItems.where((si) => !si.hideInChart)) {
      var data = siid2values[seriesItem.siid]!;
      // in case of delta ignore the first value (because it's absolute - there is no delta yet)
      // except there is only one value (if we hide it we see nothing...)
      if (data.length > 1 && (siid2useDelta[seriesItem.siid] ?? false)) {
        data.removeAt(0);
      }
      result.add(ParameterChartData(seriesDef: seriesViewMetaData.seriesDef, seriesItem: seriesItem, data: data));
    }
    return result;
  }

  static Widget buildMonthlyChartLegend(
    SeriesItem seriesItem,
    List<TimedValue> timedValues,
  ) {
    List<LegendItem> legendItems = [];

    var latestValueYear = timedValues.last.dateTime.year;
    var earliestValueYear = timedValues.first.dateTime.year;
    double maxHue = 80;
    double hueStep = latestValueYear == earliestValueYear ? 0 : maxHue / (latestValueYear - earliestValueYear);

    buildLegendItem(int year) {
      var hueSteps = latestValueYear - year;
      var color = ColorUtils.hue(seriesItem.color, hueSteps * hueStep);
      legendItems.add(LegendItem(label: year.toString(), color: color));
    }

    int actYear = earliestValueYear;
    for (var item in timedValues) {
      var year = item.dateTime.year;
      if (year != actYear) {
        buildLegendItem(actYear);
      }
      actYear = year;
    }
    buildLegendItem(actYear);

    var legend = Padding(
      padding: const EdgeInsets.only(top: ThemeUtils.verticalSpacingSmall),
      child: Wrap(
        spacing: ThemeUtils.horizontalSpacing,
        runSpacing: ThemeUtils.verticalSpacingSmall,
        children: legendItems,
      ),
    );
    return legend;
  }

  static LineChartData buildLineChartDataMonthly(
    SeriesViewMetaData seriesViewMetaData,
    SeriesItem seriesItem,
    List<TimedValue> timedValues,
    ThemeData themeData,
    Function(FlTouchEvent, LineTouchResponse?)? touchCallback,
  ) {
    List<LineChartBarData> lineBarsData = [];

    ChartMetaData chartMetaData = ChartMetaData();
    chartMetaData.showDots = false;

    var latestValueYear = timedValues.last.dateTime.year;
    var earliestValueYear = timedValues.first.dateTime.year;
    double maxHue = 80;
    double hueStep = latestValueYear == earliestValueYear ? 0 : maxHue / (latestValueYear - earliestValueYear);

    int actYear = earliestValueYear;
    List<FlSpot> values = [];

    buildLineChartData(int year) {
      var hueSteps = latestValueYear - year;
      var lineColor = ColorUtils.hue(seriesItem.color, hueSteps * hueStep);
      lineBarsData.add(
        LineChartBarData(
          spots: [...values],
          isCurved: true,
          preventCurveOverShooting: true,
          barWidth: 2,
          color: lineColor,
          dotData: ChartUtils.createDotData(chartMetaData),
          isStrokeCapRound: true,
          // dashArray: [5, 5],
          belowBarData: BarAreaData(show: true, gradient: ChartUtils.createTopToBottomGradient([lineColor.withAlpha(128), lineColor.withAlpha(0)])),
        ),
      );
    }

    for (var item in timedValues) {
      var value = item.value;
      var t = item.dateTime.month;

      var year = item.dateTime.year;
      if (year != actYear && values.isNotEmpty) {
        buildLineChartData(actYear);
        values.clear();
      }
      actYear = year;

      chartMetaData.evaluateMetaData(t, [value]);
      values.add(FlSpot(t.toDouble(), value.toDouble()));
    }

    if (values.isNotEmpty) {
      buildLineChartData(actYear);
    }

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
        // provideTooltipTextColor: (x, y, barIdx) => seriesItem.color,
        provideTooltipTextColor: (x, y, barIdx) => ColorUtils.hue(seriesItem.color, ((latestValueYear - earliestValueYear) - barIdx) * hueStep),
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
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value % 2 == 0) {
                // use chartMetaData min/max - not the value which has padding!
                return TitleBottomAxis(
                  alignment: Alignment.topCenter,
                  value: value,
                  // dateTime is here only 1...12
                  dateFormatter: (dateTime) => DateTimeUtils.getMonthShort(dateTime.millisecondsSinceEpoch),
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
    List<TimedValue> timedValues,
    ThemeData themeData,
    Function(FlTouchEvent, LineTouchResponse?)? touchCallback,
  ) {
    List<LineChartBarData> lineBarsData = [];

    ChartMetaData chartMetaData = ChartMetaData();
    chartMetaData.showDots = true;

    List<FlSpot> values = [];

    for (var item in timedValues) {
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
