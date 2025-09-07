import 'package:flutter/material.dart';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';

class SeriesDataBloodPressureAnalyticsView extends StatelessWidget {
  const SeriesDataBloodPressureAnalyticsView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<BloodPressureValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return const Placeholder();
  }
}
