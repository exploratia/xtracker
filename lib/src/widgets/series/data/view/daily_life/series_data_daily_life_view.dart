import 'package:flutter/material.dart';

import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/data/series_data_filter.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import '../series_data_view_overlays.dart';
import 'pixels/series_data_daily_life_pixels_view.dart';
import 'table/series_data_daily_life_table_view.dart';

class SeriesDataDailyLifeView extends StatelessWidget {
  const SeriesDataDailyLifeView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

  final SeriesViewMetaData seriesViewMetaData;
  final List<DailyLifeValue> seriesData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  @override
  Widget build(BuildContext context) {
    switch (seriesViewMetaData.viewType) {
      case ViewType.table:
        return SeriesDataDailyLifeTableView(
          seriesViewMetaData: seriesViewMetaData,
          seriesData: seriesData,
          seriesDataFilter: seriesDataFilter,
          seriesDataViewOverlays: seriesDataViewOverlays,
        );
      case ViewType.lineChart:
        throw UnimplementedError();
      case ViewType.barChart:
        throw UnimplementedError();
      case ViewType.dots:
        throw UnimplementedError();
      case ViewType.pixels:
        return SeriesDataDailyLifePixelsView(
          seriesViewMetaData: seriesViewMetaData,
          seriesData: seriesData,
          seriesDataFilter: seriesDataFilter,
          seriesDataViewOverlays: seriesDataViewOverlays,
        );
    }
  }
}
