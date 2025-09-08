import 'package:flutter/material.dart';

import '../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import 'trend/series_data_habit_trend_analytics_view.dart';

class SeriesDataHabitAnalyticsView extends StatelessWidget {
  const SeriesDataHabitAnalyticsView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<HabitValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SeriesDataHabitTrendAnalyticsView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
        ),
      ],
    );
  }
}
