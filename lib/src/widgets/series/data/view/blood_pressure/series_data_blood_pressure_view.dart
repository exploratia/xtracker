import 'package:flutter/material.dart';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/data/series_data_filter.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import 'chart/series_data_blood_pressure_chart_view.dart';
import 'dots/series_data_blood_pressure_dots_view.dart';
import 'table/series_data_blood_pressure_table_view.dart';

class SeriesDataBloodPressureView extends StatelessWidget {
  const SeriesDataBloodPressureView({super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter});

  final SeriesViewMetaData seriesViewMetaData;
  final List<BloodPressureValue> seriesData;
  final SeriesDataFilter seriesDataFilter;

  @override
  Widget build(BuildContext context) {
    switch (seriesViewMetaData.viewType) {
      case ViewType.table:
        return SeriesDataBloodPressureTableView(seriesViewMetaData: seriesViewMetaData, seriesData: seriesData, seriesDataFilter: seriesDataFilter);
      case ViewType.lineChart:
        return SeriesDataBloodPressureChartView(seriesViewMetaData: seriesViewMetaData, seriesData: seriesData, seriesDataFilter: seriesDataFilter);
      case ViewType.barChart:
        throw UnimplementedError();
      case ViewType.dots:
        return SeriesDataBloodPressureDotsView(seriesViewMetaData: seriesViewMetaData, seriesData: seriesData, seriesDataFilter: seriesDataFilter);
      case ViewType.pixels:
        throw UnimplementedError();
    }
  }
}
