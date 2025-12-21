import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/chart/chart_utils_custom.dart';
import '../../../../../../util/chart/chart_utils_simple_value.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/ex.dart';
import '../../../../../../util/logging/flutter_simple_logging.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/chart/chart_container.dart';
import '../../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';

class SeriesDataCustomChartView extends StatelessWidget {
  const SeriesDataCustomChartView({
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
    final themeData = Theme.of(context);

    List<CustomValue> filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
    if (filteredSeriesData.isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    String dateTimeFormatter(dateTime) => "${DateTimeUtils.formatDate(dateTime)}  ${DateTimeUtils.formatTime(dateTime)}";
    String dateFormatter(dateTime) => DateTimeUtils.formatDate(dateTime);

    List<ParameterChartData> chartDataPerParameterList;
    try {
      chartDataPerParameterList = ChartUtilsCustom.buildDataProviderPerParameter(seriesViewMetaData, filteredSeriesData);
    } catch (ex) {
      SimpleLogging.w(ex);
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        msg: (ex is Ex) ? ex.localizedMessage : null,
      );
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        List<Widget> charts = [];

        var subtractAdditionalHeights = 16 + ThemeUtils.verticalSpacing; // Title
        for (var parameterChartData in chartDataPerParameterList) {
          charts.add(
            ChartContainer(
              title: Align(
                alignment: .centerLeft,
                child: Text(parameterChartData.seriesItem.name + parameterChartData.seriesItem.unitInBrackets(emptyStringIfNullOrEmpty: true)),
              ),
              showDateTooltip: true,
              maxVisibleHeight: constraints.maxHeight - seriesDataViewOverlays.height - subtractAdditionalHeights,
              dateFormatter: dateTimeFormatter,
              chartWidgetBuilder: (touchCallback) {
                return LineChart(
                  ChartUtilsSimpleValue.buildLineChartData(
                    seriesViewMetaData,
                    parameterChartData.data,
                    themeData,
                    dateFormatter,
                    touchCallback,
                    lineColor: parameterChartData.seriesItem.color,
                    showDots: false,
                    isCurved: true,
                    showAreaBelowLine: true,
                    showToucheLine: true,
                  ),
                );
              },
            ),
          );
        }

        // Debug: show values as text
        //   for (var parameterChartData in chartDataPerParameterList) {
        //     charts.add(Text(parameterChartData.seriesItem.name));
        //     charts.addAll(parameterChartData.data.map((e) => Text(e.toString())).toList());
        // }

        return SingleChildScrollViewWithScrollbar(
          useHorizontalScreenPadding: true,
          child: Column(
            children: [
              seriesDataViewOverlays.buildTopSpacer(),
              Column(
                spacing: ThemeUtils.verticalSpacingLarge,
                children: charts,
              ),
              seriesDataViewOverlays.buildBottomSpacer(),
            ],
          ),
        );
      },
    );
  }
}
