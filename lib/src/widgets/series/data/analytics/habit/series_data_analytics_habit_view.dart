import 'package:flutter/material.dart';

import '../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../util/theme_utils.dart';
import '../series_data_analytics_days_recorded_view.dart';
import '../series_data_analytics_hours_recorded_view.dart';
import 'trend/series_data_analytics_habit_trend_view.dart';

class SeriesDataAnalyticsHabitView extends StatelessWidget {
  const SeriesDataAnalyticsHabitView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<HabitValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: ThemeUtils.screenPadding,
      children: [
        SeriesDataAnalyticsDaysRecordedView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
        ),
        SeriesDataAnalyticsHabitTrendView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
        ),
        SeriesDataAnalyticsHoursRecordedView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
        ),
      ],
    );
  }
}
