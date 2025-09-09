import 'package:flutter/material.dart';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import 'trend/series_data_analytics_blood_pressure_trend_view.dart';

class SeriesDataAnalyticsBloodPressureView extends StatelessWidget {
  const SeriesDataAnalyticsBloodPressureView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<BloodPressureValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SeriesDataAnalyticsBloodPressureTrendView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
        ),
      ],
    );
  }
}
