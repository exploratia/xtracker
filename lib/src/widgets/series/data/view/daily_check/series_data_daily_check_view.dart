import 'package:flutter/material.dart';

import '../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../model/series/data/series_data_filter.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import 'chart/series_data_daily_check_chart_view.dart';
import 'dots/series_data_daily_check_dots_view.dart';
import 'table/series_data_daily_check_table_view.dart';

class SeriesDataDailyCheckView extends StatelessWidget {
  const SeriesDataDailyCheckView({super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter});

  final SeriesViewMetaData seriesViewMetaData;
  final List<DailyCheckValue> seriesData;
  final SeriesDataFilter seriesDataFilter;

  @override
  Widget build(BuildContext context) {
    switch (seriesViewMetaData.viewType) {
      case ViewType.table:
        return SeriesDataDailyCheckTableView(seriesViewMetaData: seriesViewMetaData, seriesData: seriesData, seriesDataFilter: seriesDataFilter);
      case ViewType.lineChart:
        throw UnimplementedError();
      case ViewType.barChart:
        return SeriesDataDailyCheckChartView(seriesViewMetaData: seriesViewMetaData, seriesData: seriesData, seriesDataFilter: seriesDataFilter);
      case ViewType.dots:
        return SeriesDataDailyCheckDotsView(seriesViewMetaData: seriesViewMetaData, seriesData: seriesData, seriesDataFilter: seriesDataFilter);
      case ViewType.pixels:
        throw UnimplementedError();
    }
  }
}
