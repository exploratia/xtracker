import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/data/datetime_item.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../util/analytics/analytics.dart';
import '../../../../util/chart/chart_utils.dart';
import '../../../../util/color_utils.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/day_item/day_item.dart';
import '../../../../util/filter/after_date_filter.dart';
import '../../../../util/media_query_utils.dart';
import '../../../../util/table_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/progress/ratio_labeled_progress_bar.dart';
import 'analytics/analysis_table.dart';
import 'analytics/analytics_settings_card.dart';

class SeriesDataAnalyticsDaysRecordedView extends StatelessWidget {
  const SeriesDataAnalyticsDaysRecordedView({super.key, required this.seriesViewMetaData, required this.seriesDataValues, this.additionalEntries});

  final SeriesViewMetaData seriesViewMetaData;
  final List<SeriesDataValue> seriesDataValues;
  final List<AnalyticsSettingsCardEntry>? additionalEntries;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    List<Widget> widgets = buildDaysRecordedWidgets(context, themeData, seriesViewMetaData, seriesDataValues);

    return AnalyticsSettingsCard(
      analyticsSettingsCardEntries: [
        AnalyticsSettingsCardEntry(
          title: LocaleKeys.seriesDataAnalytics_recordedDays_title.tr(),
          infoDlgContent: SimpleInfoDlgContent(info: LocaleKeys.seriesDataAnalytics_recordedDays_label_recordedDaysInfo.tr()),
          content: Column(
            spacing: ThemeUtils.verticalSpacingLarge,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          ),
        ),
        if (additionalEntries != null) ...additionalEntries!,
      ],
    );
  }

  static List<Widget> buildDaysRecordedWidgets(
      BuildContext context, ThemeData themeData, SeriesViewMetaData seriesViewMetaData, List<SeriesDataValue> seriesDataValues) {
    var dayItems = DayItem.buildDayItems(seriesDataValues, (day) => DayItem(day), includeToday: true);

    var daysRecordedList = Analytics.datasetSizeInDays.map((lastXDays) => _DaysRecorded.analyse(dayItems, lastXDays));

    Widget recordedDaysTable = _buildRecordedDaysTable(context, seriesViewMetaData, daysRecordedList);

    Widget recordedDaysWidget = _buildRecordedDaysDistributionChart(daysRecordedList, seriesViewMetaData, themeData);

    List<Widget> children = [recordedDaysTable, recordedDaysWidget];
    return children;
  }

  static Column _buildRecordedDaysDistributionChart(Iterable<_DaysRecorded> daysRecordedList, SeriesViewMetaData seriesViewMetaData, ThemeData themeData) {
    var axisTitlesTheme = themeData.textTheme.labelLarge!;
    Widget chart = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxValue = 0;
        var chartWidth = math.max(280.0, constraints.maxWidth);
        List<BarChartGroupData> barGroups = [];
        for (int wd = 1; wd <= 7; wd++) {
          // for each weekday (1...7) calc the ratio weekday/recordedDays per dataset
          List<double> weekdayPerDataset = daysRecordedList.map((e) => (e.recordedDays == 0 ? 0.0 : e.weekDaySpread[wd] / e.recordedDays)).toList();
          maxValue = math.max(maxValue, weekdayPerDataset.fold(0, (previousValue, val) => previousValue + val));
          final barGroup = _makeGroupData(wd - 1, weekdayPerDataset, seriesViewMetaData.seriesDef.color, chartWidth > 550);
          barGroups.add(barGroup);
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween /* use full width */,
                maxY: maxValue > 0 ? null : 1,
                minY: 0,
                borderData: FlBorderData(show: false),
                barTouchData: const BarTouchData(enabled: false),
                barGroups: barGroups,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => bottomTitles(value, meta, axisTitlesTheme),
                      reservedSize: axisTitlesTheme.fontSize! * MediaQueryUtils.textScaleFactor + ThemeUtils.verticalSpacingLarge,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    var chartWidget = Column(
      spacing: ThemeUtils.verticalSpacingSmall,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LocaleKeys.seriesDataAnalytics_recordedDays_chart_chartTitle.tr(),
          style: themeData.textTheme.titleMedium,
        ),
        chart,
        Text(
          LocaleKeys.seriesDataAnalytics_recordedDays_chart_legendTitle.tr(),
          style: themeData.textTheme.labelSmall,
        ),
        Wrap(
          spacing: ThemeUtils.horizontalSpacing,
          runSpacing: ThemeUtils.verticalSpacingSmall,
          children: [
            ...Analytics.datasetSizeInDays.map(
              (s) => _buildLegendItem(s, seriesViewMetaData, themeData),
            )
          ],
        ),
      ],
    );
    return chartWidget;
  }

  static Container _buildLegendItem(int datasetSize, SeriesViewMetaData seriesViewMetaData, ThemeData themeData) {
    var gradient = _createBarGradient(seriesViewMetaData.seriesDef.color, Analytics.datasetSizeInDays.indexOf(datasetSize));
    var textColor = ColorUtils.getContrastingTextColor(gradient.colors.first);
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(ThemeUtils.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
        child: Text(
          (datasetSize == Analytics.allDays) ? LocaleKeys.seriesDataAnalytics_label_total.tr() : datasetSize.toString(),
          style: themeData.textTheme.labelSmall!.copyWith(color: textColor),
        ),
      ),
    );
  }

  static Widget bottomTitles(double value, TitleMeta meta, TextStyle axisTitlesTheme) {
    // 2025-9-1 is a monday. Add x value (0-6) to get the weekday label
    var weekdayDay = DateTimeUtils.formatShortDay(DateTime(2025, 9, 1, 12).add(Duration(days: value.toInt())));
    final Widget text = Text(
      weekdayDay,
      style: axisTitlesTheme,
    );

    return SideTitleWidget(
      meta: meta,
      space: ThemeUtils.verticalSpacing, //margin top
      child: text,
    );
  }

  /// - [x] = weekday-1
  /// - [weekDayForDataset] list of values for a certain weekday (x) for each dataset
  static BarChartGroupData _makeGroupData(int x, List<double> weekDayForDataset, Color baseColor, bool wideChart) {
    double barWidth = wideChart ? 6 : 4;
    int idx = -1;
    return BarChartGroupData(
      barsSpace: wideChart ? 6 : 3,
      x: x,
      barRods: [
        ...weekDayForDataset.map(
          (weekDayForDataSetValue) {
            return BarChartRodData(
              // instead of 0 (no bar at all) show a little dot so that every dataset is visible
              toY: math.max(0.001, weekDayForDataSetValue),
              gradient: _createBarGradient(baseColor, (++idx)),
              width: barWidth,
            );
          },
        ),
      ],
    );
  }

  /// create gradient for bars and legend
  static LinearGradient _createBarGradient(Color baseColor, int idx) {
    var barColor = ColorUtils.hue(baseColor, idx * 30);
    var gradientColor = ColorUtils.hue(barColor, -10);
    return ChartUtils.createTopToBottomGradient([barColor, gradientColor])!;
  }

  static Widget _buildRecordedDaysTable(BuildContext context, SeriesViewMetaData seriesViewMetaData, Iterable<_DaysRecorded> daysRecordedList) {
    List<TableRow> rows = _buildKeyValueTableRows(context);

    for (var daysRecorded in daysRecordedList) {
      String keyColumnText = Analytics.buildDatasetSizeString(daysRecorded.dataBasisDays);
      var keyColumnWidget = Text(
        keyColumnText,
        softWrap: false,
      );

      var valueColumnWidget = RatioLabeledProgressBar(
        color: seriesViewMetaData.seriesDef.color,
        value: daysRecorded.recordedDays,
        total: daysRecorded.countedDays,
      );

      rows.add(
        TableUtils.tableRow(
          [
            keyColumnWidget,
            valueColumnWidget,
          ],
        ),
      );
    }

    return AnalysisTable(rows: rows);
  }

  static List<TableRow> _buildKeyValueTableRows(BuildContext context) {
    List<TableRow> rows = TableUtils.buildKeyValueTableRows(
      context,
      keyColumnTitle: LocaleKeys.seriesDataAnalytics_label_dataset.tr(),
      valueColumnTitle: LocaleKeys.seriesDataAnalytics_recordedDays_label_ratio.tr(),
    );
    return rows;
  }
}

class _DaysRecorded {
  final int dataBasisDays;
  final int countedDays;
  final int recordedDays;
  final List<int> weekDaySpread;

  _DaysRecorded(this.dataBasisDays, this.countedDays, this.recordedDays, this.weekDaySpread);

  double get percentage {
    return recordedDays.toDouble() / countedDays.toDouble();
  }

  String get percentageTo100 {
    return "${(recordedDays.toDouble() / countedDays.toDouble() * 100.0).toInt()}%";
  }

  String get absoluteRate {
    return "$recordedDays / $countedDays";
  }

  static _DaysRecorded analyse(List<DayItem<DateTimeItem>> dayItems, int datasetSizeInDays) {
    // special case all
    if (datasetSizeInDays == Analytics.allDays) {
      return _DaysRecorded(datasetSizeInDays, dayItems.length, dayItems.where((di) => di.count >= 1).length, _weekDaySpread(dayItems));
    }

    AfterDateFilter dateFilter = AfterDateFilter.daysBack(datasetSizeInDays);

    var dateFiltered = dayItems.where((di) => dateFilter.filter(di.dayDate)).toList();
    var recordedDays = dateFiltered.where((di) => di.count >= 1).length;
    var countedDays = datasetSizeInDays; // dateFiltered.length could be not more but less then dateBasisDays -> counted is always datasetSizeInDays
    return _DaysRecorded(datasetSizeInDays, countedDays, recordedDays, _weekDaySpread(dateFiltered));
  }

  static List<int> _weekDaySpread(List<DayItem<DateTimeItem>> dayItems) {
    final weekdays = List<int>.filled(8, 0);
    weekdays[0] = -1;

    for (var dayItem in dayItems.where((di) => di.count >= 1)) {
      weekdays[dayItem.dayDate.weekday] += 1;
    }

    return weekdays;
  }
}
