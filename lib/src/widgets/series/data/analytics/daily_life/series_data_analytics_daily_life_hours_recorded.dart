import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/settings/daily_life/daily_life_attribute_resolver.dart';
import '../../../../../util/chart/chart_utils.dart';
import '../../../../../util/color_utils.dart';
import '../../../../../util/media_query_utils.dart';
import '../../../../../util/theme_utils.dart';

class SeriesDataAnalyticsDailyLifeHoursRecorded extends StatelessWidget {
  const SeriesDataAnalyticsDailyLifeHoursRecorded({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<DailyLifeValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    Widget recordedDaysWidget = _buildRecordedDaysDistributionChart(themeData);

    return recordedDaysWidget;
  }

  Column _buildRecordedDaysDistributionChart(ThemeData themeData) {
    var attributeResolver = DailyLifeAttributeResolver(seriesViewMetaData.seriesDef);

    var axisTitlesTheme = themeData.textTheme.labelLarge!;
    Widget chart = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var chartWidth = math.max(280.0, constraints.maxWidth);

        List<LineChartBarData> lineChartBarDataList = [];

        for (var attributeId in attributeResolver.attributeIds) {
          List<int> hours = List.generate(24, (index) => 0);
          for (var v in seriesDataValues) {
            if (v.aid == attributeId) {
              var h = v.dateTime.hour;
              hours[h] += 1;
            }
          }
          hours.add(hours.first);

          var baseColor = attributeResolver.resolve(attributeId).color;
          var gradientColor = ColorUtils.gradientColor(baseColor);
          var gradient = ChartUtils.createTopToBottomGradient([baseColor, gradientColor]);

          var spots = hours.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();

          lineChartBarDataList.add(LineChartBarData(
            gradient: gradient,
            dotData: const FlDotData(show: false),
            preventCurveOverShooting: true,
            curveSmoothness: 0.7,
            isCurved: true,
            isStrokeCapRound: true,
            isStrokeJoinRound: true,
            spots: spots,
          ));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: 120,
            child: LineChart(
              LineChartData(
                lineBarsData: lineChartBarDataList,
                // maxY: 1,
                minY: 0,
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      maxIncluded: false,
                      minIncluded: true,
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
          LocaleKeys.seriesDataAnalytics_recordedHours_chart_chartTitleDailyLife.tr(),
          style: themeData.textTheme.titleMedium,
        ),
        chart,
      ],
    );
    return chartWidget;
  }

  Widget bottomTitles(double value, TitleMeta meta, TextStyle axisTitlesTheme) {
    final Widget text = Text(
      value.toInt().toString(),
      style: axisTitlesTheme,
    );

    return SideTitleWidget(
      meta: meta,
      space: ThemeUtils.verticalSpacing, //margin top
      child: text,
    );
  }
}
