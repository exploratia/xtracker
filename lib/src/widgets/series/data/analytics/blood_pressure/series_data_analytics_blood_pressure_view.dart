import 'package:flutter/material.dart';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../util/theme_utils.dart';
import '../series_data_analytics_days_recorded_view.dart';
import '../series_data_analytics_hours_recorded_view.dart';
import 'series_data_analytics_blood_pressure_medication_days_recorded.dart';
import 'trend/series_data_analytics_blood_pressure_trend_view.dart';

class SeriesDataAnalyticsBloodPressureView extends StatelessWidget {
  const SeriesDataAnalyticsBloodPressureView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<BloodPressureValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var medicationEntry = SeriesDataAnalyticsBloodPressureMedicationDaysRecorded.buildMedication(context, themeData, seriesDataValues, seriesViewMetaData);
    return Column(
      spacing: ThemeUtils.screenPadding,
      children: [
        SeriesDataAnalyticsDaysRecordedView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
          additionalEntries: [
            if (medicationEntry != null) medicationEntry,
          ],
        ),
        SeriesDataAnalyticsHoursRecordedView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
        ),
        SeriesDataAnalyticsBloodPressureTrendView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
        ),
      ],
    );
  }
}
