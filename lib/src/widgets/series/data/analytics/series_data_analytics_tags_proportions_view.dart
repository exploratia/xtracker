import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../model/series/tags/tag.dart';
import '../../../../model/series/tags/tag_resolver.dart';
import '../../../../util/analytics/analytics.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/filter/after_date_filter.dart';
import '../../../../util/globals.dart';
import '../../../../util/pair.dart';
import '../../../../util/table_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/card/glowing_border_container.dart';
import '../../../controls/progress/ratio_labeled_progress_bar.dart';
import '../../../controls/tag/tag_renderer.dart';
import 'analytics/analysis_table.dart';
import 'analytics/analytics_settings_card.dart';

class SeriesDataAnalyticsTagsProportionsView<D extends SeriesDataValue> extends StatelessWidget {
  const SeriesDataAnalyticsTagsProportionsView({
    super.key,
    required this.seriesViewMetaData,
    required this.seriesDataValues,
    required this.tagIdResolver,
  });

  final SeriesViewMetaData seriesViewMetaData;
  final List<D> seriesDataValues;
  final String? Function(D seriesDataValue) tagIdResolver;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final tagResolver = TagResolver(seriesViewMetaData.seriesDef);

    final firstDataDateTime = seriesDataValues.first.dateTime;

    final Map<String, List<DateTime>> tagId2dates = {};
    for (var tagId in tagResolver.tagIds) {
      tagId2dates[tagId] = [];
    }

    for (var value in seriesDataValues) {
      var optTagId = tagIdResolver(value);
      if (optTagId == null || Globals.invalid == optTagId) continue;
      var resolvedTagId = tagResolver.resolve(optTagId).tagId;
      tagId2dates.putIfAbsent(resolvedTagId, () => []);
      tagId2dates[resolvedTagId]?.add(value.dateTime);
    }

    List<Pair<Tag, List<DateTime>>> sorted = [];
    for (var entry in tagId2dates.entries) {
      sorted.add(Pair(tagResolver.resolve(entry.key), entry.value));
    }
    sorted.sort((a, b) => tagResolver.compare(a.k, b.k));

    AnalysisTable totalTable = _buildTotalTable(sorted, context);

    AnalysisTable chartTable = _buildChartTable(context, sorted);

    // monthly chart
    Widget? charts = _buildDistributionCharts(sorted, firstDataDateTime, themeData);

    return AnalyticsSettingsCard.singleEntry(
      title: LocaleKeys.seriesDataAnalytics_tagsProportions_title.tr(),
      infoDlgContent: SimpleInfoDlgContent(info: LocaleKeys.seriesDataAnalytics_tagsProportions_label_tagProportionsInfo.tr()),
      content: Column(
        spacing: ThemeUtils.horizontalSpacing,
        children: [
          totalTable,
          chartTable,
          ?charts,
        ],
      ),
    );
  }

  Widget? _buildDistributionCharts(List<Pair<Tag, List<DateTime>>> sorted, DateTime firstDataDateTime, ThemeData themeData) {
    LineChartBarData buildLineChartBarData(Tag tag, List<FlSpot> spots) {
      return LineChartBarData(
        isCurved: true,
        preventCurveOverShooting: true,
        curveSmoothness: 0.7,
        color: tag.color,
        barWidth: 2,
        isStrokeCapRound: true,
        isStrokeJoinRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: spots,
      );
    }

    Widget buildBottomTitle(double value, TitleMeta meta, List<String> xTitles) {
      final idx = value.toInt();
      if (idx < 0 || idx >= xTitles.length) return const SizedBox.shrink();
      return SideTitleWidget(
        meta: meta,
        fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
        child: Text(xTitles[idx]),
      );
    }

    Widget buildDistributionChart({
      required String title,
      required List<String> xTitles,
      required List<Pair<Tag, List<int>>> tag2counts,
      required double interval,
      bool includeMin = false,
      bool includeMax = false,
    }) {
      List<LineChartBarData> lineChartBarDataList = [];
      for (var pair in tag2counts) {
        List<FlSpot> spots = pair.v.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();
        lineChartBarDataList.add(buildLineChartBarData(pair.k, spots));
      }

      var lineChartData = LineChartData(
        lineBarsData: lineChartBarDataList,
        minY: 0,
        gridData: const FlGridData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: interval,
              showTitles: true,
              minIncluded: includeMin,
              maxIncluded: includeMax,
              getTitlesWidget: (value, meta) => buildBottomTitle(value, meta, xTitles),
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              maxIncluded: false,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: ThemeUtils.verticalSpacing,
        children: [
          Text(
            title,
            style: themeData.textTheme.titleMedium,
          ),
          SizedBox(height: 160, child: _MonthlyLineChart(lineChartData: lineChartData)),
        ],
      );
    }

    // Monthly distribution
    List<Pair<Tag, Map<String, _MonthlyItem>>> attrib2MonthData = [];
    for (var pair in sorted) {
      var tag = pair.k;
      Map<String, _MonthlyItem> map = {};
      attrib2MonthData.add(Pair(tag, map));
      for (var v in pair.v) {
        var key = _MonthlyItem.buildKey(v);
        map.putIfAbsent(key, () => _MonthlyItem(v.year, v.month)).inc();
      }
    }

    List<String> monthlyXTitles = [];
    bool fillXTitles = true;
    List<Pair<Tag, List<int>>> monthlyCounts = [];
    var now = DateTime.now();
    for (var pair in attrib2MonthData) {
      Map<String, _MonthlyItem> monthlyMap = pair.v;
      List<int> monthlyList = [];
      monthlyCounts.add(Pair(pair.k, monthlyList));

      var targetMonth = DateTimeUtils.firstDayOfNextMonth(now);
      var actMonth = DateTimeUtils.firstDayOfMonth(firstDataDateTime);
      while (actMonth.isBefore(targetMonth)) {
        if (fillXTitles) {
          monthlyXTitles.add("${actMonth.month}/${actMonth.year.toString().substring(2)}");
        }
        monthlyList.add(monthlyMap.putIfAbsent(_MonthlyItem.buildKey(actMonth), () => _MonthlyItem(actMonth.year, actMonth.month)).count);
        actMonth = DateTimeUtils.firstDayOfNextMonth(actMonth);
      }
      fillXTitles = false;
    }

    List<Widget> charts = [];
    if (monthlyXTitles.length >= 2) {
      charts.add(
        buildDistributionChart(
          title: LocaleKeys.seriesDataAnalytics_tagsProportions_subTitles_monthlyDistribution.tr(),
          xTitles: monthlyXTitles,
          tag2counts: monthlyCounts,
          interval: monthlyXTitles.length > 5 ? 2 : 1,
          includeMax: true,
          includeMin: true,
        ),
      );
    }

    // Weekday distribution (Mon..Sun, all labels visible)
    final weekDayTitles = [
      LocaleKeys.commons_date_shortWeekday_monday.tr(),
      LocaleKeys.commons_date_shortWeekday_tuesday.tr(),
      LocaleKeys.commons_date_shortWeekday_wednesday.tr(),
      LocaleKeys.commons_date_shortWeekday_thursday.tr(),
      LocaleKeys.commons_date_shortWeekday_friday.tr(),
      LocaleKeys.commons_date_shortWeekday_saturday.tr(),
      LocaleKeys.commons_date_shortWeekday_sunday.tr(),
    ];
    List<Pair<Tag, List<int>>> weekDayCounts = [];
    for (var pair in sorted) {
      List<int> counts = List.filled(7, 0);
      for (var dateTime in pair.v) {
        counts[dateTime.weekday - 1] += 1;
      }
      weekDayCounts.add(Pair(pair.k, counts));
    }
    charts.add(
      buildDistributionChart(
        title: LocaleKeys.seriesDataAnalytics_tagsProportions_subTitles_distributionWeekdays.tr(),
        xTitles: weekDayTitles,
        tag2counts: weekDayCounts,
        interval: 1,
        includeMin: true,
        includeMax: true,
      ),
    );

    // Hour distribution (every 2nd label)
    List<String> hourTitles = List.generate(24, (index) => index.toString());
    List<Pair<Tag, List<int>>> hourCounts = [];
    for (var pair in sorted) {
      List<int> counts = List.filled(24, 0);
      for (var dateTime in pair.v) {
        counts[dateTime.hour] += 1;
      }
      hourCounts.add(Pair(pair.k, counts));
    }
    charts.add(
      buildDistributionChart(
        title: LocaleKeys.seriesDataAnalytics_tagsProportions_subTitles_distributionHours.tr(),
        xTitles: hourTitles,
        tag2counts: hourCounts,
        interval: 2,
        includeMin: false,
      ),
    );

    if (charts.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: ThemeUtils.verticalSpacingLarge,
      children: charts,
    );
  }

  AnalysisTable _buildChartTable(BuildContext context, List<Pair<Tag, List<DateTime>>> sorted) {
    List<TableRow> rows = TableUtils.buildKeyValueTableRows(
      context,
      keyColumnTitle: LocaleKeys.seriesDataAnalytics_label_dataset.tr(),
      valueColumnTitle: LocaleKeys.seriesDataAnalytics_tagsProportions_table_colProportions.tr(),
    );

    List<Pair<Tag, List<DateTime>>> reduced = [...sorted];
    for (var days in Analytics.datasetSizeInDays.reversed) {
      String keyColumnText = Analytics.buildDatasetSizeString(days);
      var keyColumnWidget = Text(
        keyColumnText,
        softWrap: false,
      );

      var filter = AfterDateFilter.daysBack(days);
      List<Pair<Tag, List<DateTime>>> reducedTmp = [];
      for (var r in reduced) {
        reducedTmp.add(Pair(r.k, r.v.where((e) => filter.filter(e)).toList()));
      }

      var valueColumnWidget = _ProportionsChart(
        tagProportions: reducedTmp.map(
          (e) => Pair(e.k, e.v.length),
        ),
      );

      rows.insert(
        1,
        TableUtils.tableRow(
          [
            keyColumnWidget,
            valueColumnWidget,
          ],
        ),
      );

      reduced = reducedTmp;
    }

    return AnalysisTable(rows: rows);
  }

  AnalysisTable _buildTotalTable(List<Pair<Tag, List<DateTime>>> sorted, BuildContext context) {
    var total = sorted.fold(0, (previousValue, p) => previousValue + p.v.length);

    List<TableRow> totalRows = TableUtils.buildKeyValueTableRows(
      context,
      keyColumnTitle: LocaleKeys.seriesDataAnalytics_tagsProportions_table_colTag.tr(),
      valueColumnTitle: LocaleKeys.seriesDataAnalytics_tagsProportions_table_colTotalShare.tr(),
    );

    for (var p in sorted) {
      var keyColumnWidget = TagRenderer(tag: p.k);

      var valueColumnWidget = RatioLabeledProgressBar(
        color: p.k.color,
        value: p.v.length,
        total: total,
      );

      totalRows.add(
        TableUtils.tableRow(
          [
            keyColumnWidget,
            valueColumnWidget,
          ],
        ),
      );
    }

    var totalTable = AnalysisTable(rows: totalRows);
    return totalTable;
  }
}

class _MonthlyLineChart extends StatefulWidget {
  const _MonthlyLineChart({
    required this.lineChartData,
  });

  final LineChartData lineChartData;

  @override
  State<_MonthlyLineChart> createState() => _MonthlyLineChartState();
}

class _MonthlyLineChartState extends State<_MonthlyLineChart> {
  // auto zooming and panning to the end is at the moment not so easy...
  // https://github.com/imaNNeo/fl_chart/issues/71

  // late TransformationController _transformationController;
  //
  // @override
  // void initState() {
  //   _transformationController = TransformationController();
  //   _transformationController.value *= Matrix4.diagonal3Values(
  //     5.1,
  //     1,
  //     1,
  //   );
  //   _transformationController.value *= Matrix4.translationValues(
  //     -200,
  //     0,
  //     0,
  //   );
  //   super.initState();
  // }
  //
  // @override
  // void dispose() {
  //   _transformationController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      transformationConfig: const FlTransformationConfig(
        panEnabled: true,
        scaleEnabled: false,
        minScale: 1,
        maxScale: 20,
        scaleAxis: FlScaleAxis.horizontal,
        // transformationController: _transformationController,
      ),
      widget.lineChartData,
    );
  }
}

class _MonthlyItem {
  final int year;
  final int month;
  int idx = 0;
  int count = 0;

  _MonthlyItem(this.year, this.month);

  void inc() => count++;

  DateTime get toDate => DateTime(year, month);

  FlSpot get flSpot => FlSpot(idx.toDouble(), count.toDouble());

  static String buildKey(DateTime dateTime) => "${dateTime.year}-${dateTime.month}";
}

class _ProportionsChart extends StatelessWidget {
  const _ProportionsChart({
    required this.tagProportions,
  });

  final Iterable<Pair<Tag, int>> tagProportions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ThemeUtils.borderRadiusSmall * 2,
      child: Row(
        children: [
          ...tagProportions
              .where((p) => p.v > 0)
              .map(
                (p) => Expanded(
                  flex: p.v,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: GlowingBorderContainer.createGlowingBoxDecoration(
                      p.k.color,
                      backgroundGradientColors: TagRenderer.buildTagGradient(p.k.color),
                      borderRadius: ThemeUtils.borderRadiusSmall,
                      blurRadius: ThemeUtils.borderRadiusSmall,
                      borderWidth: 1,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
