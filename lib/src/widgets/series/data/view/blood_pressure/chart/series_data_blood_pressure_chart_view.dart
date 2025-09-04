import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/chart/chart_utils_blood_pressure.dart';
import '../../../../../controls/chart/chart_container.dart';
import '../../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';

class SeriesDataBloodPressureChartView extends StatelessWidget {
  const SeriesDataBloodPressureChartView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

  final SeriesViewMetaData seriesViewMetaData;
  final List<BloodPressureValue> seriesData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    var filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
    if (filteredSeriesData.isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollViewWithScrollbar(
        useHorizontalScreenPadding: true,
        child: Column(
          children: [
            seriesDataViewOverlays.buildTopSpacer(),
            ChartContainer(
              showDateTooltip: true,
              maxVisibleHeight: constraints.maxHeight - seriesDataViewOverlays.height,
              chartWidgetBuilder: (touchCallback) {
                return LineChart(
                  ChartUtilsBloodPressure.buildLineChartData(filteredSeriesData, themeData, touchCallback, context),
                );
              },
            ),
            seriesDataViewOverlays.buildBottomSpacer(),
          ],
        ),
      );
    });
  }
}
