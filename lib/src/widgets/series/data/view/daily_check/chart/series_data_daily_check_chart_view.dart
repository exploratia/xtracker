import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/chart/chart_utils_simple_value.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/chart/chart_container.dart';
import '../../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../series_data_no_data.dart';

class SeriesDataDailyCheckChartView extends StatelessWidget {
  const SeriesDataDailyCheckChartView({super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter});

  final SeriesViewMetaData seriesViewMetaData;
  final List<DailyCheckValue> seriesData;
  final SeriesDataFilter seriesDataFilter;

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

    List<SimpleValue> combinedSeriesData = _buildDataProvider();

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollViewWithScrollbar(
        useScreenPadding: false,
        useHorizontalScreenPadding: true,
        child: Column(
          children: [
            ChartContainer(
              showDateTooltip: true,
              maxVisibleHeight: constraints.maxHeight - ThemeUtils.seriesDataBottomFilterViewHeight,
              dateFormatter: seriesViewMetaData.showYearly ? DateTimeUtils.formateYear : DateTimeUtils.formateMonthYear,
              chartWidgetBuilder: (touchCallback) {
                return LineChart(
                  ChartUtilsSimpleValue.buildLineChartData(seriesViewMetaData, combinedSeriesData, themeData, touchCallback),
                );
              },
            ),
            const SizedBox(
              height: ThemeUtils.seriesDataBottomFilterViewHeight,
            ),
          ],
        ),
      );
    });
  }

  List<SimpleValue> _buildDataProvider() {
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
    return combinedSeriesData;
  }
}
