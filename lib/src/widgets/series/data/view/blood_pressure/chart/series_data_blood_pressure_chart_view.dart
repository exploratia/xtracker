import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/chart/chart_utils_blood_pressure.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/chart/chart_container.dart';
import '../../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';

class SeriesDataBloodPressureChartView extends StatelessWidget {
  const SeriesDataBloodPressureChartView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesViewMetaData seriesViewMetaData;
  final SeriesData<BloodPressureValue> seriesData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return SingleChildScrollViewWithScrollbar(
      child: Padding(
        padding: const EdgeInsets.only(top: ThemeUtils.seriesDataViewTopPadding),
        child: Column(
          children: [
            ChartContainer(
              showDateTooltip: true,
              chartWidgetBuilder: (maxWidth, touchCallback) {
                DateTime reduceToNewerThen =
                    DateTimeUtils.firstDayOfYear(DateTimeUtils.truncateToDay(DateTime.timestamp().subtract(const Duration(days: 365 * 5))));
                // in case of chart reduce to max available pixels
                DateTime reduceToNewerThenPxWidth = DateTimeUtils.truncateToDay(DateTime.timestamp().subtract(Duration(days: (maxWidth * 0.8).truncate())));
                DateTime reduceToNewerThenMax = reduceToNewerThenPxWidth.isAfter(reduceToNewerThen) ? reduceToNewerThenPxWidth : reduceToNewerThen;

                return LineChart(
                  ChartUtilsBloodPressure.buildLineChartData(seriesData.reduceToNewerThen(reduceToNewerThenMax), themeData, touchCallback),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
