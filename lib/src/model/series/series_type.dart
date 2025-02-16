import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'view_type.dart';

enum SeriesType {
  bloodPressure('bloodPressure', 'monitor_heart_outlined', Colors.red, [ViewType.table, ViewType.chart, ViewType.dots]),
  dailyCheck("dailyCheck", 'check_box_outlined', Colors.blue, [ViewType.dots]),
  monthly("monthly", 'calendar_month_outlined', Colors.deepPurple, [ViewType.table, ViewType.chart]),
  free("free", 'calendar_today_outlined', Colors.green, [ViewType.table, ViewType.chart]);

  final String typeName;
  final String iconName;
  final Color color;
  final List<ViewType> viewTypes;

  const SeriesType(this.typeName, this.iconName, this.color, this.viewTypes);

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
