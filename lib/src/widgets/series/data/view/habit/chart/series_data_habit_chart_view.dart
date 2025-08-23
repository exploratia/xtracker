import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/chart/chart_utils_simple_value.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../controls/chart/chart_container.dart';
import '../../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';

class SeriesDataHabitChartView extends StatelessWidget {
  const SeriesDataHabitChartView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesViewMetaData seriesViewMetaData;
  final List<HabitValue> seriesData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    List<SimpleValue> combinedSeriesData = [];
    SimpleValue? actSimpleValue;
    for (var seriesItem in seriesData) {
      var dateTime = seriesViewMetaData.showYearly ? DateTimeUtils.firstDayOfYear(seriesItem.dateTime) : DateTimeUtils.firstDayOfMonth(seriesItem.dateTime);
      if (actSimpleValue == null || actSimpleValue.dateTime != dateTime) {
        actSimpleValue = SimpleValue(dateTime);
        combinedSeriesData.add(actSimpleValue);
      } else {
        actSimpleValue.increment();
      }
    }

    return SingleChildScrollViewWithScrollbar(
      child: Column(
        children: [
          ChartContainer(
            showDateTooltip: true,
            dateFormatter: seriesViewMetaData.showYearly ? DateTimeUtils.formateYear : DateTimeUtils.formateMonthYear,
            chartWidgetBuilder: (maxWidth, touchCallback) {
              DateTime reduceToNewerThen =
                  DateTimeUtils.firstDayOfYear(DateTimeUtils.truncateToDay(DateTime.timestamp().subtract(const Duration(days: 365 * 5))));
              // in case of chart reduce to max available pixels
              DateTime reduceToNewerThenPxWidth = DateTimeUtils.truncateToDay(
                  DateTime.timestamp().subtract(Duration(days: 31 * (seriesViewMetaData.showYearly ? 12 : 1) * (maxWidth * 0.8).truncate())));
              DateTime reduceToNewerThenMax = reduceToNewerThenPxWidth.isAfter(reduceToNewerThen) ? reduceToNewerThenPxWidth : reduceToNewerThen;

              combinedSeriesData = combinedSeriesData.where((item) => item.dateTime.isAfter(reduceToNewerThenMax)).toList();

              return LineChart(
                ChartUtilsSimpleValue.buildLineChartData(seriesViewMetaData, combinedSeriesData, themeData, touchCallback),
              );
            },
          ),
        ],
      ),
    );
  }
}
