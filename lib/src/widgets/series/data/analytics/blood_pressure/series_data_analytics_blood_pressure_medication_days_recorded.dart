import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/series_view_meta_data.dart';
import '../../../../../util/date_time_utils.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/renderer/number_gradient_renderer.dart';
import '../analytics/analytics_settings_card.dart';
import '../series_data_analytics_days_recorded_view.dart';

class SeriesDataAnalyticsBloodPressureMedicationDaysRecorded {
  static AnalyticsSettingsCardEntry? buildMedication(
      BuildContext context, ThemeData themeData, List<BloodPressureValue> seriesDataValues, SeriesViewMetaData seriesViewMetaData) {
    // no medication input?
    if (seriesViewMetaData.seriesDef.bloodPressureSettingsReadonly().hideMedicationInput) return null;

    var medicationDays = seriesDataValues.where((v) => v.medication).toList();
    Widget lastMedicationDays = _buildLastMedicationDays(themeData, medicationDays, seriesViewMetaData);

    return AnalyticsSettingsCardEntry(
      title: LocaleKeys.seriesDataAnalytics_bloodPressure_recordedDaysMedication_title.tr(),
      content: Column(
        spacing: ThemeUtils.verticalSpacingLarge,
        children: [
          ...SeriesDataAnalyticsDaysRecordedView.buildDaysRecordedWidgets(context, themeData, seriesViewMetaData, medicationDays),
          lastMedicationDays,
        ],
      ),
    );
  }

  static Widget _buildLastMedicationDays(ThemeData themeData, List<BloodPressureValue> medicationDays, SeriesViewMetaData seriesViewMetaData) {
    var now = DateTime.now();
    int daysBack = 28;
    var dateFilter = DateTimeBuilder.now().truncateToMidDay.subtract(Duration(days: daysBack + 1)).endOfDay.dateTime;
    var medicationDaysFilteredDates = medicationDays.where((v) => v.datetime.isAfter(dateFilter) && v.datetime.isBefore(now)).map((e) => e.datetime).toList();
    var list = List.generate(daysBack + 1, (index) => 0);
    for (var medicationDay in medicationDaysFilteredDates) {
      list[now.difference(medicationDay).inDays]++;
    }

    var lastMedicationDays = Column(
      spacing: ThemeUtils.verticalSpacingSmall,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LocaleKeys.seriesDataAnalytics_bloodPressure_recordedDaysMedication_label_medicationLastDays.tr(),
          style: themeData.textTheme.titleMedium,
        ),
        if (medicationDaysFilteredDates.isNotEmpty)
          NumberGradientRenderer(
            numbers: list.reversed,
            baseColor: seriesViewMetaData.seriesDef.color,
          ),
        if (medicationDaysFilteredDates.isEmpty) const Text(" - -"),
      ],
    );
    return lastMedicationDays;
  }
}
