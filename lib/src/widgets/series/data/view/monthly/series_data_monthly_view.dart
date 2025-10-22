import 'package:flutter/material.dart';

import '../../../../../model/series/data/monthly/monthly_value.dart';
import '../../../../../model/series/data/series_data_filter.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import '../series_data_view_overlays.dart';
import 'table/series_data_monthly_table_view.dart';

class SeriesDataMonthlyView extends StatelessWidget {
  const SeriesDataMonthlyView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

  final SeriesViewMetaData seriesViewMetaData;
  final List<MonthlyValue> seriesData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  @override
  Widget build(BuildContext context) {
    switch (seriesViewMetaData.viewType) {
      case ViewType.table:
        return SeriesDataMonthlyTableView(
          seriesViewMetaData: seriesViewMetaData,
          seriesData: seriesData,
          seriesDataFilter: seriesDataFilter,
          seriesDataViewOverlays: seriesDataViewOverlays,
        );
      case ViewType.lineChart:
      case ViewType.barChart:
      case ViewType.pixels:
      case ViewType.dots:
        throw UnimplementedError();
    }
  }
}
