import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import '../../../../../providers/series_data_provider.dart';
import '../../../../../util/date_time_utils.dart';
import '../../../../layout/centered_message.dart';
import 'chart/series_data_daily_check_chart_view.dart';
import 'dots/series_data_daily_check_dots_view.dart';
import 'table/series_data_blood_pressure_table_view.dart';

class SeriesDataDailyCheckView extends StatelessWidget {
  const SeriesDataDailyCheckView({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    final seriesDef = seriesViewMetaData.seriesDef;

    var seriesDataProvider = context.watch<SeriesDataProvider>();
    var dailyCheckSeriesData = seriesDataProvider.dailyCheckData(seriesDef);
    if (dailyCheckSeriesData == null || dailyCheckSeriesData.isEmpty()) {
      return CenteredMessage(
        message: IntrinsicHeight(
          child: Column(
            children: [
              Icon(seriesDef.iconData(), color: seriesDef.color, size: 40),
              Text(LocaleKeys.series_data_noData.tr()),
            ],
          ),
        ),
      );
    }

    switch (seriesViewMetaData.viewType) {
      case ViewType.dots:
        {
          DateTime reduceToNewerThen = DateTimeUtils.firstDayOfYear(DateTimeUtils.truncateToDay(DateTime.timestamp().subtract(const Duration(days: 365 * 5))));
          return SeriesDataDailyCheckDotsView(seriesViewMetaData: seriesViewMetaData, seriesData: dailyCheckSeriesData.reduceToNewerThen(reduceToNewerThen));
        }
      case ViewType.table:
        return SeriesDataDailyCheckTableView(seriesViewMetaData: seriesViewMetaData, seriesData: dailyCheckSeriesData);
      case ViewType.lineChart:
        throw UnimplementedError();
      case ViewType.barChart:
        return SeriesDataDailyCheckChartView(seriesViewMetaData: seriesViewMetaData, seriesData: dailyCheckSeriesData);
    }
  }
}
