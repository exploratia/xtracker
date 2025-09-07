import 'package:flutter/material.dart';

import '../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';

class SeriesDataHabitAnalyticsView extends StatelessWidget {
  const SeriesDataHabitAnalyticsView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<HabitValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Column(
      children: [
        Text("data"),
        Placeholder(
          fallbackHeight: 300,
        ),
        Text("data"),
        Placeholder(
          fallbackHeight: 300,
        ),
        Text("data"),
        Placeholder(
          fallbackHeight: 300,
        ),
      ],
    );
  }
}
