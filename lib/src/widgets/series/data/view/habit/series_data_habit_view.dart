import 'package:flutter/material.dart';

import '../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../model/series/data/series_data_filter.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import 'chart/series_data_habit_chart_view.dart';
import 'pixels/series_data_habit_pixels_view.dart';
import 'table/series_data_habit_table_view.dart';

class SeriesDataHabitView extends StatelessWidget {
  const SeriesDataHabitView({super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter});

  final SeriesViewMetaData seriesViewMetaData;
  final List<HabitValue> seriesData;
  final SeriesDataFilter seriesDataFilter;

  @override
  Widget build(BuildContext context) {
    switch (seriesViewMetaData.viewType) {
      case ViewType.table:
        return SeriesDataHabitTableView(seriesViewMetaData: seriesViewMetaData, seriesData: seriesData);
      case ViewType.lineChart:
        throw UnimplementedError();
      case ViewType.barChart:
        return SeriesDataHabitChartView(seriesViewMetaData: seriesViewMetaData, seriesData: seriesData);
      case ViewType.dots:
        throw UnimplementedError();
      case ViewType.pixels:
        return SeriesDataHabitPixelsView(seriesViewMetaData: seriesViewMetaData, seriesData: seriesData, seriesDataFilter: seriesDataFilter);
    }
  }
}
