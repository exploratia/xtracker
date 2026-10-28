import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/chart/chart_meta_data.dart';
import '../../model/series/data/monthly/monthly_value.dart';
import '../../model/series/seriesItem/series_item.dart';
import '../../model/series/series_view_meta_data.dart';
import '../../widgets/controls/chart/legend_item.dart';
import '../../widgets/controls/chart/title_bottom_axis.dart';
import '../color_utils.dart';
import '../date_time_utils.dart';
import '../ex.dart';
import '../media_query_utils.dart';
import '../theme_utils.dart';
import 'chart_delta_filter.dart';
import 'chart_utils.dart';
import 'chart_utils_custom.dart';
import 'chart_utils_simple_value.dart';

class ChartUtilsMonthly {
  static List<ParameterChartData> buildDataProviderPerParameter(SeriesViewMetaData seriesViewMetaData, List<MonthlyValue> seriesData) {
    final result = <ParameterChartData>[];
    if (!seriesViewMetaData.showCompressed) {
      DateTime? previousTimestamp;
      for (final row in seriesData) {
        if (row.dateTime == previousTimestamp) {
          throw Ex(
            "Found duplicate timestamp '$previousTimestamp' in monthly data in series '${seriesViewMetaData.seriesDef.name}'!",
            localizedMessage: LocaleKeys.seriesData_monthly_msg_duplicateTimestamp.tr(args: [DateTimeUtils.formatMonthYear(row.dateTime)]),
          );
        }
        previousTimestamp = row.dateTime;
      }
    }
    for (final item in seriesViewMetaData.seriesDef.seriesItems.where((item) => !item.hideInChart)) {
      final readings = <TimedValue>[
        for (final row in seriesData)
          if (row.values[item.siid] case final value? when value.isFinite) TimedValue.value(row.dateTime, value),
      ];
      final compressed = seriesViewMetaData.showCompressed;
      final useDelta = item.useDeltaInChart && readings.length > 1 && (!compressed || readings.first.dateTime.year != readings.last.dateTime.year);
      var data = useDelta ? ChartDeltaFilter.buildDeltas(readings, filterOutliers: item.filterDeltaOutliersInChart) : readings;
      if (compressed) {
        // Include the baseline year to preserve the existing omission of the
        // first, incomplete year. Filter monthly transitions before summing.
        data = _compressYearly(useDelta ? [readings.first, ...data] : data, sumDeltas: useDelta);
        if (useDelta) data.removeAt(0);
      }
      result.add(ParameterChartData(seriesDef: seriesViewMetaData.seriesDef, seriesItem: item, data: data));
    }
    return result;
  }

  static List<TimedValue> _compressYearly(List<TimedValue> values, {required bool sumDeltas}) {
    final result = <TimedValue>[];
    for (final value in values) {
      final timestamp = DateTimeUtils.firstDayOfYear(value.dateTime);
      if (result.isEmpty || result.last.dateTime != timestamp) {
        result.add(TimedValue.value(timestamp, value.value));
      } else if (sumDeltas) {
        // A missing transition makes the entire annual total unknown.
        result.last.add(value.value);
      } else {
        result.last.set(value.value);
      }
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
      legendItems.add(LegendItem(label: (year % 1000).toString(), color: color));
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

    var legend = Wrap(
      spacing: ThemeUtils.horizontalSpacing,
      runSpacing: ThemeUtils.verticalSpacingSmall,
      children: legendItems,
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
    final lineYears = <int>[];

    ChartMetaData chartMetaData = ChartMetaData();
    chartMetaData.showDots = false;

    var latestValueYear = timedValues.last.dateTime.year;
    var earliestValueYear = timedValues.first.dateTime.year;
    double maxHue = 80;
    double hueStep = latestValueYear == earliestValueYear ? 0 : maxHue / (latestValueYear - earliestValueYear);

    int actYear = earliestValueYear;
    List<FlSpot> values = [];

    buildLineChartData(int year) {
      lineYears.add(year);
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

      chartMetaData.evaluateMetaData(t, item.isGap ? [] : [value]);
      values.add(item.isGap ? FlSpot.nullSpot : FlSpot(t.toDouble(), value.toDouble()));
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
        showToucheLine: true,
        themeData: themeData,
        touchCallback: touchCallback,
        provideTooltipTextColor: (x, y, barIdx) => lineBarsData[barIdx].color!,
        provideTooltipExt: (x, y, barIndex) => [TextSpan(text: "   (${lineYears[barIndex]})", style: themeData.textTheme.labelSmall)],
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

      chartMetaData.evaluateMetaData(t, item.isGap ? [] : [value]);

      values.add(item.isGap ? FlSpot.nullSpot : FlSpot(t.toDouble(), value.toDouble()));
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
                value: value.toInt(),
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
