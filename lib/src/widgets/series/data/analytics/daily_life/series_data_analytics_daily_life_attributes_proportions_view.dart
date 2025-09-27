import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/settings/daily_life/daily_life_attribute.dart';
import '../../../../../model/series/settings/daily_life/daily_life_attribute_resolver.dart';
import '../../../../../util/analytics/analytics.dart';
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

    return AnalyticsSettingsCard(
      title: LocaleKeys.seriesDataAnalytics_dailyLife_attributesProportions_title.tr(),
      infoDlgContent: SimpleInfoDlgContent(info: LocaleKeys.seriesDataAnalytics_dailyLife_attributesProportions_label_attributeProportionsInfo.tr()),
      children: [
        totalTable,
        chartTable,
      ],
    );
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
