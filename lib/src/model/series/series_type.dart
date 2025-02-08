import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum SeriesType {
  bloodPressure('bloodPressure', Icon(Icons.monitor_heart_outlined)),
  dailyCheck("dailyCheck", Icon(Icons.check_circle_outline)),
  monthly("monthly", Icon(Icons.calendar_month_outlined)),
  free("free", Icon(Icons.calendar_today));

  final String typeName;
  final Icon icon;

  const SeriesType(this.typeName, this.icon);

  static String displayNameOf(SeriesType seriesType, AppLocalizations t) {
    return switch (seriesType) {
      SeriesType.bloodPressure => t.seriesSeriesTypeBloodPressure,
      SeriesType.dailyCheck => t.seriesSeriesTypeDailyCheck,
      SeriesType.monthly => t.seriesSeriesTypeMonthly,
      SeriesType.free => t.seriesSeriesTypeFree,
    };
  }

  static String infoOf(SeriesType seriesType, AppLocalizations t) {
    return switch (seriesType) {
      SeriesType.bloodPressure => t.seriesSeriesTypeBloodPressureInfo,
      SeriesType.dailyCheck => t.seriesSeriesTypeDailyCheckInfo,
      SeriesType.monthly => t.seriesSeriesTypeMonthlyInfo,
      SeriesType.free => t.seriesSeriesTypeFreeInfo,
    };
  }
}
