import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/chart/chart_utils_daily_check.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../chart/chart_container.dart';
import '../../../../../layout/single_child_scroll_view_with_scrollbar.dart';

class SeriesDataDailyCheckChartView extends StatelessWidget {
  const SeriesDataDailyCheckChartView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesViewMetaData seriesViewMetaData;
  final SeriesData<DailyCheckValue> seriesData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    List<CombinedValue> combinedSeriesData = [];
    CombinedValue? actCombinedValue;
    for (var seriesItem in seriesData.seriesItems) {
      var dateTime = seriesViewMetaData.showYearly ? DateTimeUtils.firstDayOfYear(seriesItem.dateTime) : DateTimeUtils.firstDayOfMonth(seriesItem.dateTime);
      if (actCombinedValue == null || actCombinedValue.dateTime != dateTime) {
        actCombinedValue = CombinedValue(dateTime);
        combinedSeriesData.add(actCombinedValue);
      } else {
        actCombinedValue.increment();
      }
    }

    return SingleChildScrollViewWithScrollbar(
      child: Padding(
        padding: const EdgeInsets.only(top: ThemeUtils.seriesDataViewTopPadding),
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
                  ChartUtilsDailyCheck.buildLineChartData(
                      seriesViewMetaData, seriesData.reduceToNewerThen(reduceToNewerThenMax), combinedSeriesData, themeData, touchCallback),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
