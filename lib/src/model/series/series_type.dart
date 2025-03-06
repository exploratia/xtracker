import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'view_type.dart';

enum SeriesType {
  bloodPressure(
    'bloodPressure',
    'monitor_heart_outlined',
    Colors.red,
    [
      ViewType.dots,
      ViewType.chart,
      ViewType.table,
    ],
  ),
  dailyCheck("dailyCheck", 'check_box_outlined', Colors.blue, [ViewType.dots]),
  monthly("monthly", 'calendar_month_outlined', Colors.deepPurple, [ViewType.table, ViewType.chart]),
  free("free", 'calendar_today_outlined', Colors.green, [ViewType.chart, ViewType.table]);
  // TODO TimeTracker

  final String typeName;
  final String iconName;
  final Color color;

  /// order is used in AppBar actions and last one is used as default/first view
  final List<ViewType> viewTypes;

  const SeriesType(this.typeName, this.iconName, this.color, this.viewTypes);

  static SeriesType byTypeName(String typeName) {
    return SeriesType.values.firstWhere((element) => element.typeName == typeName, orElse: () => throw Exception("Unexpected SeriesType '$typeName'"));
  }

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
