import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../model/series/data/custom/custom_value.dart';
import '../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../model/series/data/habit/habit_value.dart';
import '../../../../model/series/data/monthly/monthly_value.dart';
import '../../../../model/series/data/series_data_filter.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../providers/series_data_provider.dart';
import 'blood_pressure/series_data_blood_pressure_view.dart';
import 'custom/series_data_custom_view.dart';
import 'daily_check/series_data_daily_check_view.dart';
import 'daily_life/series_data_daily_life_view.dart';
import 'habit/series_data_habit_view.dart';
import 'monthly/series_data_monthly_view.dart';
import 'series_data_view_overlays.dart';

class SeriesDataViewContentBuilder extends StatelessWidget {
  const SeriesDataViewContentBuilder({
    super.key,
    required this.seriesViewMetaData,
    required this.builder,
    required this.seriesDataFilter,
    required this.seriesDataViewOverlays,
  });

  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;
  final Widget Function(Widget Function() seriesDataViewBuilder, List<SeriesDataValue> seriesDataValues) builder;

  @override
  Widget build(BuildContext context) {
    SeriesDef seriesDef = seriesViewMetaData.seriesDef;
    var seriesDataProvider = context.watch<SeriesDataProvider>();

    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        var seriesData = seriesDataProvider.bloodPressureData(seriesDef);
        List<BloodPressureValue> values = seriesData?.data ?? [];
        return builder(
          () => SeriesDataBloodPressureView(
            seriesViewMetaData: seriesViewMetaData,
            seriesData: values,
            seriesDataFilter: seriesDataFilter,
            seriesDataViewOverlays: seriesDataViewOverlays,
          ),
          values,
        );

      case SeriesType.dailyCheck:
        var seriesData = seriesDataProvider.dailyCheckData(seriesDef);
        List<DailyCheckValue> values = seriesData?.data ?? [];
        return builder(
          () => SeriesDataDailyCheckView(
            seriesViewMetaData: seriesViewMetaData,
            seriesData: values,
            seriesDataFilter: seriesDataFilter,
            seriesDataViewOverlays: seriesDataViewOverlays,
          ),
          values,
        );

      case SeriesType.dailyLife:
        var seriesData = seriesDataProvider.dailyLifeData(seriesDef);
        List<DailyLifeValue> values = seriesData?.data ?? [];
        return builder(
          () => SeriesDataDailyLifeView(
            seriesViewMetaData: seriesViewMetaData,
            seriesData: values,
            seriesDataFilter: seriesDataFilter,
            seriesDataViewOverlays: seriesDataViewOverlays,
          ),
          values,
        );

      case SeriesType.habit:
        var seriesData = seriesDataProvider.habitData(seriesDef);
        List<HabitValue> values = seriesData?.data ?? [];
        return builder(
          () => SeriesDataHabitView(
            seriesViewMetaData: seriesViewMetaData,
            seriesData: values,
            seriesDataFilter: seriesDataFilter,
            seriesDataViewOverlays: seriesDataViewOverlays,
          ),
          values,
        );

      case SeriesType.custom:
        var seriesData = seriesDataProvider.customData(seriesDef);
        List<CustomValue> values = seriesData?.data ?? [];
        return builder(
          () => SeriesDataCustomView(
            seriesViewMetaData: seriesViewMetaData,
            seriesData: values,
            seriesDataFilter: seriesDataFilter,
            seriesDataViewOverlays: seriesDataViewOverlays,
          ),
          values,
        );

      case SeriesType.monthly:
        var seriesData = seriesDataProvider.monthlyData(seriesDef);
        List<MonthlyValue> values = seriesData?.data ?? [];
        return builder(
          () => SeriesDataMonthlyView(
            seriesViewMetaData: seriesViewMetaData,
            seriesData: values,
            seriesDataFilter: seriesDataFilter,
            seriesDataViewOverlays: seriesDataViewOverlays,
          ),
          values,
        );
    }
  }
}
