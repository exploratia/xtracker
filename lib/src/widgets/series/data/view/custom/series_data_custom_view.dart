import 'package:material_ui/material_ui.dart';

import '../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../model/series/data/series_data_filter.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import '../series_data_view_overlays.dart';
import 'chart/series_data_custom_chart_view.dart';
import 'pixels/series_data_custom_pixels_view.dart';
import 'table/series_data_custom_table_view.dart';

class SeriesDataCustomView extends StatelessWidget {
  const SeriesDataCustomView({
    super.key,
    required this.seriesViewMetaData,
    required this.seriesData,
    required this.seriesDataFilter,
    required this.seriesDataViewOverlays,
  });

  final SeriesViewMetaData seriesViewMetaData;
  final List<CustomValue> seriesData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  @override
  Widget build(BuildContext context) {
    switch (seriesViewMetaData.viewType) {
      case ViewType.table:
        return SeriesDataCustomTableView(
          seriesViewMetaData: seriesViewMetaData,
          seriesData: seriesData,
          seriesDataFilter: seriesDataFilter,
          seriesDataViewOverlays: seriesDataViewOverlays,
        );
      case ViewType.lineChart:
        return SeriesDataCustomChartView(
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
