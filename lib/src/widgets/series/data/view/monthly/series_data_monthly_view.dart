import 'package:flutter/material.dart';

import '../../../../../model/series/data/monthly/monthly_value.dart';
import '../../../../../model/series/data/series_data_filter.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import '../custom/pixels/series_data_custom_pixels_view.dart';
import '../custom/table/series_data_custom_table_view.dart';
import '../series_data_view_overlays.dart';
import 'chart/series_data_monthly_chart_view.dart';

class SeriesDataMonthlyView extends StatelessWidget {
  const SeriesDataMonthlyView({
    super.key,
    required this.seriesViewMetaData,
    required this.seriesData,
    required this.seriesDataFilter,
    required this.seriesDataViewOverlays,
  });

  final SeriesViewMetaData seriesViewMetaData;
  final List<MonthlyValue> seriesData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  @override
  Widget build(BuildContext context) {
    switch (seriesViewMetaData.viewType) {
      case ViewType.table:
        // at the moment no difference to custom
        return SeriesDataCustomTableView(
          seriesViewMetaData: seriesViewMetaData,
          seriesData: seriesData,
          seriesDataFilter: seriesDataFilter,
          seriesDataViewOverlays: seriesDataViewOverlays,
        );
      case ViewType.lineChart:
        return SeriesDataMonthlyChartView(
          seriesViewMetaData: seriesViewMetaData,
          seriesData: seriesData,
          seriesDataFilter: seriesDataFilter,
          seriesDataViewOverlays: seriesDataViewOverlays,
        );
      case ViewType.barChart:
        throw UnimplementedError();
      case ViewType.pixels:
        return SeriesDataCustomPixelsView(
          seriesViewMetaData: seriesViewMetaData,
          seriesData: seriesData,
          seriesDataFilter: seriesDataFilter,
          seriesDataViewOverlays: seriesDataViewOverlays,
        );
    }
  }
}
