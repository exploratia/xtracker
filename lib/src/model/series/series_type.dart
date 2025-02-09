import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum SeriesType {
  bloodPressure('bloodPressure', 'monitor_heart_outlined', Colors.red),
  dailyCheck("dailyCheck", 'check_box_outlined', Colors.blue),
  monthly("monthly", 'calendar_month_outlined', Colors.deepPurple),
  free("free", 'calendar_today_outlined', Colors.green);

  final String typeName;
  final String iconName;
  final Color color;

  const SeriesType(this.typeName, this.iconName, this.color);

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
