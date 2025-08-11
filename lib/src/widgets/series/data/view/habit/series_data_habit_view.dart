import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../model/series/view_type.dart';
import '../../../../../providers/series_data_provider.dart';
import '../../../../controls/animation/fade_in.dart';
import '../../../../controls/layout/centered_message.dart';
import 'chart/series_data_habit_chart_view.dart';
import 'table/series_data_habit_table_view.dart';

class SeriesDataHabitView extends StatelessWidget {
  const SeriesDataHabitView({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    final seriesDef = seriesViewMetaData.seriesDef;

    var seriesDataProvider = context.watch<SeriesDataProvider>();
    var habitSeriesData = seriesDataProvider.habitData(seriesDef);
    if (habitSeriesData == null || habitSeriesData.isEmpty()) {
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
      case ViewType.dots:
        throw UnimplementedError();
      case ViewType.table:
        return SeriesDataHabitTableView(seriesViewMetaData: seriesViewMetaData, seriesData: habitSeriesData);
      case ViewType.lineChart:
        throw UnimplementedError();
      case ViewType.barChart:
        return SeriesDataHabitChartView(seriesViewMetaData: seriesViewMetaData, seriesData: habitSeriesData);
    }
  }
}
