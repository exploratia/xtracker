import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../../../generated/locale_keys.g.dart';
import '../../../../../../model/series/data/monthly/monthly_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/chart/chart_utils_custom.dart';
import '../../../../../../util/chart/chart_utils_monthly.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/ex.dart';
import '../../../../../../util/logging/flutter_simple_logging.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/chart/chart_container.dart';
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
    final themeData = Theme.of(context);

    List<MonthlyValue> filteredSeriesData;
    // in case of yearly compression ignore any date filter.
    if (seriesViewMetaData.showCompressed) {
      filteredSeriesData = seriesData;
    } else {
      filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
      if (filteredSeriesData.isEmpty) {
        return SeriesDataNoData(
          seriesViewMetaData: seriesViewMetaData,
          noDataBecauseOfFilter: true,
        );
      }
    }

    var dateFormatter = seriesViewMetaData.showCompressed ? DateTimeUtils.formatYear : DateTimeUtils.formatMonthYear;

    List<ParameterChartData> chartDataPerParameterList;
    try {
      chartDataPerParameterList = ChartUtilsMonthly.buildDataProviderPerParameter(seriesViewMetaData, filteredSeriesData);
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

        if (seriesViewMetaData.showCompressed) {
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
                dateFormatter: dateFormatter,
                chartWidgetBuilder: (touchCallback) {
                  return LineChart(
                    ChartUtilsMonthly.buildLineChartDataYearly(
                      seriesViewMetaData,
                      parameterChartData.seriesItem,
                      parameterChartData.data,
                      themeData,
                      null,
                    ),
                  );
                },
              ),
            );
          }
        } else {
          var subtractAdditionalHeights = 16 + ThemeUtils.verticalSpacing; // +12+ ThemeUtils.verticalSpacing; // Title + Legend
          for (var parameterChartData in chartDataPerParameterList) {
            Widget chartWidget;
            if (parameterChartData.data.isEmpty) {
              chartWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: .centerLeft,
                    child: Text(parameterChartData.seriesItem.name + parameterChartData.seriesItem.unitInBrackets(emptyStringIfNullOrEmpty: true)),
                  ),
                  const Divider(),
                  Center(child: Text(LocaleKeys.seriesData_label_noData.tr())),
                  const Divider(),
                ],
              );
            } else {
              chartWidget = ChartContainer(
                title: Align(
                  alignment: .centerLeft,
                  child: Text(parameterChartData.seriesItem.name + parameterChartData.seriesItem.unitInBrackets(emptyStringIfNullOrEmpty: true)),
                ),
                legend: ChartUtilsMonthly.buildMonthlyChartLegend(
                  parameterChartData.seriesItem,
                  parameterChartData.data,
                ),
                showDateTooltip: true,
                maxVisibleHeight: constraints.maxHeight - seriesDataViewOverlays.height - subtractAdditionalHeights,
                dateFormatter: dateFormatter,
                chartWidgetBuilder: (touchCallback) {
                  return LineChart(
                    ChartUtilsMonthly.buildLineChartDataMonthly(
                      seriesViewMetaData,
                      parameterChartData.seriesItem,
                      parameterChartData.data,
                      themeData,
                      null,
                    ),
                  );
                },
              );
            }

            charts.add(chartWidget);
          }
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
              const SizedBox(height: ThemeUtils.verticalSpacingSmall),
              seriesDataViewOverlays.buildBottomSpacer(),
            ],
          ),
        );
      },
    );
  }
}
