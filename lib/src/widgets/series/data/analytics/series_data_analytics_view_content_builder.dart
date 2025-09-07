import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../model/series/data/habit/habit_value.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../providers/series_data_provider.dart';
import 'blood_pressure/series_data_blood_pressure_analytics_view.dart';
import 'daily_check/series_data_daily_check_analytics_view.dart';
import 'habit/series_data_habit_analytics_view.dart';

class SeriesDataAnalyticsViewContentBuilder extends StatelessWidget {
  const SeriesDataAnalyticsViewContentBuilder({
    super.key,
    required this.seriesViewMetaData,
    required this.builder,
  });

  final SeriesViewMetaData seriesViewMetaData;
  final Widget Function(Widget Function() seriesDataViewBuilder) builder;

  @override
  Widget build(BuildContext context) {
    SeriesDef seriesDef = seriesViewMetaData.seriesDef;
    var seriesDataProvider = context.read<SeriesDataProvider>();

    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        var seriesData = seriesDataProvider.bloodPressureData(seriesDef);
        List<BloodPressureValue> values = seriesData?.data ?? [];
        return builder(
          () => SeriesDataBloodPressureAnalyticsView(
            seriesViewMetaData: seriesViewMetaData,
            seriesDataValues: values,
          ),
        );

      case SeriesType.dailyCheck:
        var seriesData = seriesDataProvider.dailyCheckData(seriesDef);
        List<DailyCheckValue> values = seriesData?.data ?? [];
        return builder(
          () => SeriesDataDailyCheckAnalyticsView(
            seriesViewMetaData: seriesViewMetaData,
            seriesDataValues: values,
          ),
        );

      case SeriesType.habit:
        var seriesData = seriesDataProvider.habitData(seriesDef);
        List<HabitValue> values = seriesData?.data ?? [];
        return builder(
          () => SeriesDataHabitAnalyticsView(
            seriesViewMetaData: seriesViewMetaData,
            seriesDataValues: values,
          ),
        );
    }
  }
}
