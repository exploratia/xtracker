import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/settings/daily_life/daily_life_attribute.dart';
import '../../../../../model/series/settings/daily_life/daily_life_attribute_resolver.dart';
import '../../../../../util/analytics/analytics.dart';
import '../../../../../util/date_time_utils.dart';
import '../../../../../util/filter/after_date_filter.dart';
import '../../../../../util/pair.dart';
import '../../../../../util/table_utils.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/card/glowing_border_container.dart';
import '../../../../controls/progress/ratio_labeled_progress_bar.dart';
import '../../view/daily_life/daily_life_attribute_renderer.dart';
import '../analytics/analysis_table.dart';
import '../analytics/analytics_settings_card.dart';

class SeriesDataAnalyticsDailyLifeAttributesProportionsView extends StatelessWidget {
  const SeriesDataAnalyticsDailyLifeAttributesProportionsView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<DailyLifeValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final attributeResolver = DailyLifeAttributeResolver(seriesViewMetaData.seriesDef);

    final Map<String, List<DateTime>> aid2dates = {};
    for (var aid in attributeResolver.attributeIds) {
      aid2dates[aid] = [];
    }

    for (var value in seriesDataValues) {
      var resolvedAttributeId = attributeResolver.resolve(value.aid).aid;
      aid2dates.putIfAbsent(resolvedAttributeId, () => []);
      aid2dates[resolvedAttributeId]?.add(value.dateTime);
    }

    List<Pair<DailyLifeAttribute, List<DateTime>>> sorted = [];
    for (var entry in aid2dates.entries) {
      sorted.add(Pair(attributeResolver.resolve(entry.key), entry.value));
    }
    sorted.sort((a, b) => attributeResolver.compare(a.k, b.k));

    AnalysisTable totalTable = _buildTotalTable(sorted, context);

    AnalysisTable chartTable = _buildChartTable(context, sorted);

    // monthly chart
    Widget? monthlyChart = _buildMonthlyChart(sorted, themeData);

    return AnalyticsSettingsCard(
      title: LocaleKeys.seriesDataAnalytics_dailyLife_attributesProportions_title.tr(),
      infoDlgContent: SimpleInfoDlgContent(info: LocaleKeys.seriesDataAnalytics_dailyLife_attributesProportions_label_attributeProportionsInfo.tr()),
      children: [
        totalTable,
        chartTable,
        if (monthlyChart != null) monthlyChart,
      ],
    );
  }

  Widget? _buildMonthlyChart(List<Pair<DailyLifeAttribute, List<DateTime>>> sorted, ThemeData themeData) {
    // monthly chart
    List<Pair<DailyLifeAttribute, Map<String, _MonthlyItem>>> attrib2MonthData = [];
    for (var pair in sorted) {
      var attribute = pair.k;
      Map<String, _MonthlyItem> map = {};
      attrib2MonthData.add(Pair(attribute, map));

      for (var v in pair.v) {
        var key = _MonthlyItem.buildKey(v);
        map.putIfAbsent(key, () => _MonthlyItem(v.year, v.month)).inc();
      }
    }

    // build lists with all dates
    List<String> xTitles = [];
    bool fillXTitles = true; // for the first attribute fill xTitles list

    List<Pair<DailyLifeAttribute, List<_MonthlyItem>>> attrib2MonthDataList = [];
    var now = DateTime.now();
    for (var pair in attrib2MonthData) {
      Map<String, _MonthlyItem> monthlyMap = pair.v;
      List<_MonthlyItem> monthlyList = [];
      attrib2MonthDataList.add(Pair(pair.k, monthlyList));

      var targetMonth = DateTimeUtils.firstDayOfNextMonth(now);
      var actMonth = DateTimeUtils.firstDayOfMonth(seriesDataValues.first.dateTime);
      int idx = 0;
      while (actMonth.isBefore(targetMonth)) {
        if (fillXTitles) {
          xTitles.add("${actMonth.month}/${actMonth.year.toString().substring(2)}");
        }

        var monthItem = monthlyMap.putIfAbsent(_MonthlyItem.buildKey(actMonth), () => _MonthlyItem(actMonth.year, actMonth.month));
        monthItem.idx = idx;
        idx++;
        monthlyList.add(monthItem);
        actMonth = DateTimeUtils.firstDayOfNextMonth(actMonth);
      }

      fillXTitles = false;
    }
    Widget? monthlyChart;
    if (xTitles.length >= 2) {
      // build chart
      List<LineChartBarData> lineChartBarDataList = [];
      for (var pair in attrib2MonthDataList) {
        var attrib = pair.k;
        var data = pair.v;

        List<FlSpot> spots = [];
        for (var monthlyItem in data) {
          spots.add(monthlyItem.flSpot);
        }

        lineChartBarDataList.add(
          LineChartBarData(
            isCurved: true,
            color: attrib.color,
            barWidth: 2,
            isStrokeCapRound: true,
            isStrokeJoinRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            preventCurveOverShooting: true,
            spots: spots,
          ),
        );
      }

      var flTitlesData = FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            // interval: 1,
            showTitles: true,
            maxIncluded: false,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(meta: meta, child: Text(xTitles[value.toInt()]));
            },
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      );
      var lineChartData = LineChartData(
        lineBarsData: lineChartBarDataList,
        minY: 0,
        gridData: const FlGridData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        titlesData: flTitlesData,
      );
      Widget lineChart = _MonthlyLineChart(lineChartData: lineChartData);

      monthlyChart = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: ThemeUtils.verticalSpacing,
        children: [
          Text(
            LocaleKeys.seriesDataAnalytics_dailyLife_attributesProportions_subTitles_monthlyDistribution.tr(),
            style: themeData.textTheme.titleMedium,
          ),
          SizedBox(height: 160, child: lineChart),
        ],
      );
    }
    return monthlyChart;
  }

  AnalysisTable _buildChartTable(BuildContext context, List<Pair<DailyLifeAttribute, List<DateTime>>> sorted) {
    List<TableRow> rows = TableUtils.buildKeyValueTableRows(
      context,
      keyColumnTitle: LocaleKeys.seriesDataAnalytics_label_dataset.tr(),
      valueColumnTitle: LocaleKeys.seriesDataAnalytics_dailyLife_attributesProportions_table_colProportions.tr(),
    );

    List<Pair<DailyLifeAttribute, List<DateTime>>> reduced = [...sorted];
    for (var days in Analytics.datasetSizeInDays.reversed) {
      String keyColumnText = Analytics.buildDatasetSizeString(days);
      var keyColumnWidget = Text(
        keyColumnText,
        softWrap: false,
      );

      var filter = AfterDateFilter.daysBack(days);
      List<Pair<DailyLifeAttribute, List<DateTime>>> reducedTmp = [];
      for (var r in reduced) {
        reducedTmp.add(Pair(r.k, r.v.where((e) => filter.filter(e)).toList()));
      }

      var valueColumnWidget = _ProportionsChart(
        attributeProportions: reducedTmp.map(
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

  AnalysisTable _buildTotalTable(List<Pair<DailyLifeAttribute, List<DateTime>>> sorted, BuildContext context) {
    var total = sorted.fold(0, (previousValue, p) => previousValue + p.v.length);

    List<TableRow> totalRows = TableUtils.buildKeyValueTableRows(
      context,
      keyColumnTitle: LocaleKeys.seriesDataAnalytics_dailyLife_attributesProportions_table_colAttribute.tr(),
      valueColumnTitle: LocaleKeys.seriesDataAnalytics_dailyLife_attributesProportions_table_colTotalShare.tr(),
    );

    for (var p in sorted) {
      var keyColumnWidget = DailyLifeAttributeRenderer(dailyLifeAttribute: p.k);

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
    required this.attributeProportions,
  });

  final Iterable<Pair<DailyLifeAttribute, int>> attributeProportions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ThemeUtils.borderRadiusSmall * 2,
      child: Row(
        children: [
          ...attributeProportions.where((p) => p.v > 0).map(
                (p) => Expanded(
                  flex: p.v,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: GlowingBorderContainer.createGlowingBoxDecoration(
                      p.k.color,
                      backgroundGradientColors: DailyLifeAttributeRenderer.buildAttributeGradient(p.k.color),
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
