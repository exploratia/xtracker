import 'package:flutter/material.dart';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import 'trend/series_data_bloodpressure_trend_analytics_view.dart';

class SeriesDataBloodPressureAnalyticsView extends StatelessWidget {
  const SeriesDataBloodPressureAnalyticsView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<BloodPressureValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SeriesDataBloodPressureTrendAnalyticsView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
        ),
      ],
    );
  }
}
