import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/chart/chart_utils_simple_value.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../controls/chart/chart_container.dart';
import '../../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';

class SeriesDataHabitChartView extends StatelessWidget {
  const SeriesDataHabitChartView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

  final SeriesViewMetaData seriesViewMetaData;
  final List<HabitValue> seriesData;
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

    List<SimpleValue> combinedSeriesData = _buildDataProvider(filteredSeriesData);
    var dateFormatter = seriesViewMetaData.showCompressed ? DateTimeUtils.formatMonthYear : DateTimeUtils.formatDate;

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollViewWithScrollbar(
        useHorizontalScreenPadding: true,
        child: Column(
          children: [
            seriesDataViewOverlays.buildTopSpacer(),
            ChartContainer(
              showDateTooltip: true,
              maxVisibleHeight: constraints.maxHeight - seriesDataViewOverlays.height,
              dateFormatter: dateFormatter,
              chartWidgetBuilder: (touchCallback) {
                return LineChart(
                  ChartUtilsSimpleValue.buildLineChartData(seriesViewMetaData, combinedSeriesData, themeData, dateFormatter, touchCallback),
                );
              },
            ),
            seriesDataViewOverlays.buildBottomSpacer(),
          ],
        ),
      );
    });
  }

  List<SimpleValue> _buildDataProvider(List<HabitValue> filteredSeriesData) {
    List<SimpleValue> combinedSeriesData = [];
    SimpleValue? actSimpleValue;
    for (var seriesItem in filteredSeriesData) {
      var dateTime = seriesViewMetaData.showCompressed ? DateTimeUtils.firstDayOfMonth(seriesItem.dateTime) : DateTimeUtils.truncateToDay(seriesItem.dateTime);
      if (actSimpleValue == null || actSimpleValue.dateTime != dateTime) {
        actSimpleValue = SimpleValue(dateTime);
        combinedSeriesData.add(actSimpleValue);
      } else {
        actSimpleValue.increment();
      }
    }
    return combinedSeriesData;
  }
}
