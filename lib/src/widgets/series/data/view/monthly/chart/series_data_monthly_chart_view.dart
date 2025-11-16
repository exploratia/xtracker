import 'package:flutter/material.dart';

import '../../../../../../model/series/data/monthly/monthly_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';

class SeriesDataMonthlyChartView extends StatelessWidget {
  const SeriesDataMonthlyChartView({
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
    var filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
    if (filteredSeriesData.isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        List<Widget> charts = [];

        if (seriesViewMetaData.showCompressed) {
          charts.add(const Text("compressed"));
        } else {
          charts.add(const Text("not compressed"));
        }

        // charts.add(
        //   ChartContainer(
        //     showDateTooltip: true,
        //     maxVisibleHeight: constraints.maxHeight - seriesDataViewOverlays.height,
        //     chartWidgetBuilder: (touchCallback) {
        //       return LineChart(
        //         ChartUtilsMonthly.buildLineChartData(filteredSeriesData, themeData, touchCallback, context),
        //       );
        //     },
        //   ),
        // );

        return SingleChildScrollViewWithScrollbar(
          useHorizontalScreenPadding: true,
          child: Column(
            children: [
              seriesDataViewOverlays.buildTopSpacer(),
              ...charts,
              seriesDataViewOverlays.buildBottomSpacer(),
            ],
          ),
        );
      },
    );
  }
}
