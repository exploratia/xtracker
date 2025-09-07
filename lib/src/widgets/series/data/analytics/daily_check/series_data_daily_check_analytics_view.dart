import 'package:flutter/material.dart';

import '../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';

class SeriesDataDailyCheckAnalyticsView extends StatelessWidget {
  const SeriesDataDailyCheckAnalyticsView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<DailyCheckValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return const Placeholder();
  }
}
