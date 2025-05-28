import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import 'view_type.dart';

enum SeriesType {
  bloodPressure('bloodPressure', 'monitor_heart_outlined', Colors.red, [ViewType.dots, ViewType.lineChart, ViewType.table]),
  dailyCheck("dailyCheck", 'check_box_outlined', Colors.blue, [ViewType.dots, ViewType.barChart, ViewType.table]),
  monthly("monthly", 'calendar_month_outlined', Colors.deepPurple, [ViewType.table, ViewType.lineChart]),
  free("free", 'calendar_today_outlined', Colors.green, [ViewType.lineChart, ViewType.table]);
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

  static String displayNameOf(SeriesType seriesType) {
    return switch (seriesType) {
      SeriesType.bloodPressure => LocaleKeys.series_seriesType_bloodPressure_title.tr(),
      SeriesType.dailyCheck => LocaleKeys.series_seriesType_dailyCheck_title.tr(),
      SeriesType.monthly => LocaleKeys.series_seriesType_monthly_title.tr(),
      SeriesType.free => LocaleKeys.series_seriesType_free_title.tr(),
    };
  }

  static String infoOf(SeriesType seriesType) {
    return switch (seriesType) {
      SeriesType.bloodPressure => LocaleKeys.series_seriesType_bloodPressure_info.tr(),
      SeriesType.dailyCheck => LocaleKeys.series_seriesType_dailyCheck_info.tr(),
      SeriesType.monthly => LocaleKeys.series_seriesType_monthly_info.tr(),
      SeriesType.free => LocaleKeys.series_seriesType_free_info.tr(),
    };
  }
}
