import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import '../../../../../providers/series_data_provider.dart';
import '../../../../../util/date_time_utils.dart';
import '../../../../controls/animation/fade_in.dart';
import '../../../../controls/layout/centered_message.dart';
import 'chart/series_data_blood_pressure_chart_view.dart';
import 'dots/series_data_blood_pressure_dots_view.dart';
import 'table/series_data_blood_pressure_table_view.dart';

class SeriesDataBloodPressureView extends StatelessWidget {
  const SeriesDataBloodPressureView({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    final seriesDef = seriesViewMetaData.seriesDef;

    var seriesDataProvider = context.watch<SeriesDataProvider>();
    var bloodPressureSeriesData = seriesDataProvider.bloodPressureData(seriesDef);
    if (bloodPressureSeriesData == null || bloodPressureSeriesData.isEmpty()) {
      return CenteredMessage(
        message: IntrinsicHeight(
          child: FadeIn(
            child: Column(
              children: [
                Icon(seriesDef.iconData(), color: seriesDef.color, size: 40),
                Text(LocaleKeys.seriesData_label_noData.tr()),
              ],
            ),
          ),
        ),
      );
    }

    switch (seriesViewMetaData.viewType) {
      case ViewType.table:
        return SeriesDataBloodPressureTableView(seriesViewMetaData: seriesViewMetaData, seriesData: bloodPressureSeriesData);
      case ViewType.lineChart:
        return SeriesDataBloodPressureChartView(seriesViewMetaData: seriesViewMetaData, seriesData: bloodPressureSeriesData);
      case ViewType.barChart:
        throw UnimplementedError();
      case ViewType.dots:
        {
          DateTime reduceToNewerThen = DateTimeUtils.firstDayOfYear(DateTimeUtils.truncateToDay(DateTime.timestamp().subtract(const Duration(days: 365 * 5))));
          return SeriesDataBloodPressureDotsView(
              seriesViewMetaData: seriesViewMetaData, seriesData: bloodPressureSeriesData.reduceToNewerThen(reduceToNewerThen));
        }
      case ViewType.pixels:
        throw UnimplementedError();
    }
  }
}
