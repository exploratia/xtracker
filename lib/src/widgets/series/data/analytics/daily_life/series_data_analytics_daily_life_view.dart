import 'package:flutter/material.dart';

import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../util/theme_utils.dart';
import '../series_data_analytics_days_recorded_view.dart';

class SeriesDataAnalyticsDailyLifeView extends StatelessWidget {
  const SeriesDataAnalyticsDailyLifeView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<DailyLifeValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: ThemeUtils.screenPadding,
      children: [
        SeriesDataAnalyticsDaysRecordedView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
        ),
      ],
    );
  }
}
