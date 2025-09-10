import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/data/datetime_item.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../util/chart/chart_utils.dart';
import '../../../../util/color_utils.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/day_item/day_item.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/media_query_utils.dart';
import '../../../../util/table_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/card/settings_card.dart';
import '../../../controls/layout/h_centered_scroll_view.dart';
import '../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../controls/progress/progress_bar.dart';
import '../../../controls/text/overflow_text.dart';

class SeriesDataAnalyticsDaysRecordedView extends StatelessWidget {
  static const int _allDays = -1;
  static const List<int> _datasetSizeInDays = [7, 30, 90, 365, _allDays];

  const SeriesDataAnalyticsDaysRecordedView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<SeriesDataValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var dayItems = DayItem.buildDayItems(seriesDataValues, (day) => DayItem(day), includeToday: true);

    var daysRecordedList = _datasetSizeInDays.map((lastXDays) => _DaysRecorded.analyse(dayItems, lastXDays));

    Widget recordedDaysTable = _buildRecordedDaysTable(context, daysRecordedList);

    Widget recordedDaysWidget = _buildRecordedDaysDistributionChart(daysRecordedList, themeData);

    return _DaysRecordedViewSettingsCard(
      trendInfoDialogContent: const _DaysRecordedInfoDialogContent(),
      children: [
        recordedDaysTable,
        recordedDaysWidget,
      ],
    );
  }

  Column _buildRecordedDaysDistributionChart(Iterable<_DaysRecorded> daysRecordedList, ThemeData themeData) {
    var axisTitlesTheme = themeData.textTheme.labelLarge!;
    Widget chart = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var chartWidth = math.max(280.0, constraints.maxWidth);
        List<BarChartGroupData> barGroups = [];
        for (int wd = 1; wd <= 7; wd++) {
          // for each weekday (1...7) calc the ratio weekday/recordedDays per dataset
          List<double> weekdayPerDataset = daysRecordedList.map((e) => (e.recordedDays == 0 ? 0.0 : e.weekDaySpread[wd] / e.recordedDays)).toList();
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
                // maxY: 1,
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
            ..._datasetSizeInDays.map(
              (s) => _buildLegendItem(s, themeData),
            )
          ],
        ),
      ],
    );
    return chartWidget;
  }

  Container _buildLegendItem(int datasetSize, ThemeData themeData) {
    var gradient = _createBarGradient(seriesViewMetaData.seriesDef.color, _datasetSizeInDays.indexOf(datasetSize));
    var textColor = ColorUtils.getContrastingTextColor(gradient.colors.first);
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(ThemeUtils.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
        child: Text(
          (datasetSize == _allDays) ? LocaleKeys.seriesDataAnalytics_label_total.tr() : datasetSize.toString(),
          style: themeData.textTheme.labelSmall!.copyWith(color: textColor),
        ),
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta, TextStyle axisTitlesTheme) {
    // 2025-9-1 is a monday. Add x value (0-6) to get the weekday label
    var weekdayDay = DateTimeUtils.formateShortDay(DateTime(2025, 9, 1, 12).add(Duration(days: value.toInt())));
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
  BarChartGroupData _makeGroupData(int x, List<double> weekDayForDataset, Color baseColor, bool wideChart) {
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
  LinearGradient _createBarGradient(Color baseColor, int idx) {
    var barColor = ColorUtils.hue(baseColor, idx * 30);
    var gradientColor = ColorUtils.hue(barColor, -10);
    return ChartUtils.createTopToBottomGradient([barColor, gradientColor])!;
  }

  Widget _buildRecordedDaysTable(BuildContext context, Iterable<_DaysRecorded> daysRecordedList) {
    List<TableRow> rows = _AnalysisTable.buildKeyValueTableRows(context);

    for (var daysRecorded in daysRecordedList) {
      String keyColumnText = _buildDatasetSizeString(daysRecorded.dataBasisDays);
      var keyColumnWidget = Text(
        keyColumnText,
        softWrap: false,
      );

      var valueColumnWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProgressBar(
            value: daysRecorded.percentage,
            color: seriesViewMetaData.seriesDef.color,
            padding: const EdgeInsets.only(
              top: ThemeUtils.verticalSpacingSmall,
              bottom: ThemeUtils.verticalSpacingSmall,
              left: ThemeUtils.horizontalSpacing,
            ),
          ),
          Row(
            spacing: ThemeUtils.horizontalSpacingLarge,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                child: Align(
                  alignment: AlignmentGeometry.centerRight,
                  child: Text(daysRecorded.percentageTo100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: ThemeUtils.defaultPadding),
                child: Text(daysRecorded.absoluteRate),
              ),
            ],
          ),
        ],
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

    return _AnalysisTable(rows: rows);
  }

  static String _buildDatasetSizeString(int size) {
    var sizeString = LocaleKeys.seriesDataAnalytics_label_lastVarDays.tr(args: [size.toString()]);
    if (size == _allDays) {
      sizeString = LocaleKeys.seriesDataAnalytics_label_total.tr();
    }
    return sizeString;
  }
}

class _DaysRecordedViewSettingsCard extends StatelessWidget {
  const _DaysRecordedViewSettingsCard({
    required this.trendInfoDialogContent,
    required this.children,
  });

  final Widget trendInfoDialogContent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      spacing: ThemeUtils.verticalSpacingLarge,
      title: Row(
        spacing: ThemeUtils.horizontalSpacing,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OverflowText(
            LocaleKeys.seriesDataAnalytics_recordedDays_title.tr(),
            style: Theme.of(context).textTheme.titleLarge,
            expanded: false,
            flexible: true,
          ),
          IconButton(
            tooltip: LocaleKeys.commons_btn_info_tooltip.tr(),
            onPressed: () => Dialogs.simpleOkDialog(
              SingleChildScrollViewWithScrollbar(
                useHorizontalScreenPaddingForScrollbar: true,
                child: trendInfoDialogContent,
              ),
              context,
              title: LocaleKeys.seriesDataAnalytics_recordedDays_title.tr(),
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      children: children,
    );
  }
}

class _DaysRecordedInfoDialogContent extends StatelessWidget {
  const _DaysRecordedInfoDialogContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: ThemeUtils.verticalSpacingLarge,
      children: [
        Text(LocaleKeys.seriesDataAnalytics_recordedDays_label_recordedDaysInfo.tr()),
      ],
    );
  }
}

class _AnalysisTable extends StatelessWidget {
  const _AnalysisTable({
    required this.rows,
  });

  final List<TableRow> rows;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => HCenteredScrollView(
        children: [
          Table(
            columnWidths: <int, TableColumnWidth>{
              0: const FixedColumnWidth(120),
              1: FixedColumnWidth(math.max(120, constraints.maxWidth - 120)),
            },
            border: TableBorder.symmetric(
              inside: BorderSide(width: 1, color: themeData.canvasColor),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows,
          ),
        ],
      ),
    );
  }

  static List<TableRow> buildKeyValueTableRows(BuildContext context) {
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
    if (datasetSizeInDays == SeriesDataAnalyticsDaysRecordedView._allDays) {
      return _DaysRecorded(datasetSizeInDays, dayItems.length, dayItems.where((di) => di.count >= 1).length, _weekDaySpread(dayItems));
    }

    var dateFilter = DateTimeUtils.truncateToDay(DateTimeUtils.truncateToDay(DateTime.now()).subtract(Duration(days: datasetSizeInDays - 1, microseconds: 1)));
    var dateFiltered = dayItems.where((di) => di.dayDate.isAfter(dateFilter)).toList();
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
