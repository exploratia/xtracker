import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../util/ex.dart';
import '../../util/theme_utils.dart';
import '../../widgets/controls/select/icon_map.dart';
import '../column_profile/fix_column_profile_type.dart';
import 'view_type.dart';

enum SeriesType {
  bloodPressure(
    'bloodPressure',
    Icons.monitor_heart_outlined,
    Colors.red,
    [
      ViewType.dots,
      ViewType.lineChart,
      ViewType.table,
    ],
    [
      FixColumnProfileType.dateTimeValue,
      FixColumnProfileType.dateDayRange,
      FixColumnProfileType.dateHourlyOverview,
      FixColumnProfileType.dateMorningMiddayEvening,
    ],
  ),
  dailyCheck(
    "dailyCheck",
    Icons.check_box_outlined,
    Colors.blue,
    [
      ViewType.barChart,
      ViewType.table,
      ViewType.dots,
    ],
    [
      FixColumnProfileType.dateTimeValue,
      FixColumnProfileType.dateDayRange,
      FixColumnProfileType.dateHourlyOverview,
      FixColumnProfileType.dateMorningMiddayEvening,
    ],
  ),
  habit(
    "habit",
    Icons.repeat_outlined,
    Color.fromRGBO(255, 154, 0, 1.0),
    [
      ViewType.barChart,
      ViewType.table,
      ViewType.pixels,
    ],
    [
      FixColumnProfileType.dateTimeValue,
      FixColumnProfileType.dateDayRange,
      FixColumnProfileType.dateHourlyOverview,
      FixColumnProfileType.dateMorningMiddayEvening,
    ],
  ),
  dailyLife(
    "dailyLife",
    Icons.account_circle_outlined,
    Color.fromRGBO(0, 255, 50, 1.0),
    [
      ViewType.table,
      ViewType.pixels,
    ],
    [
      FixColumnProfileType.dateDayRange,
      FixColumnProfileType.dateHourlyOverview,
      FixColumnProfileType.dateTimeValue,
    ],
  ),
  custom(
    "custom",
    Icons.line_axis_outlined,
    ThemeUtils.primaryColor,
    [ViewType.table],
    [], // no fix table column profiles
  ),
  ;

  final String typeName;
  final IconData iconData;
  final Color color;

  /// order is used in AppBar actions and last one is used as default/first view
  final List<ViewType> viewTypes;

  /// last one is used as default
  final List<FixColumnProfileType> tableFixColumnProfileTypes;

  /// [iconData] one of [IconMap]
  const SeriesType(this.typeName, this.iconData, this.color, this.viewTypes, this.tableFixColumnProfileTypes);

  ViewType get defaultViewType {
    return viewTypes.last;
  }

  FixColumnProfileType? get defaultFixTableColumnProfileType {
    if (tableFixColumnProfileTypes.isEmpty) return null;
    return tableFixColumnProfileTypes.last;
  }

  String get displayName => displayNameOf(this);

  List<FixColumnProfileType> get sortedTableFixColumnProfileTypes {
    return [...tableFixColumnProfileTypes]..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  static SeriesType byTypeName(String typeName) {
    return SeriesType.values.firstWhere((element) => element.typeName == typeName, orElse: () => throw Ex("Unexpected SeriesType '$typeName'"));
  }

  static String displayNameOf(SeriesType seriesType) {
    return switch (seriesType) {
      SeriesType.bloodPressure => LocaleKeys.enum_seriesType_bloodPressure_title.tr(),
      SeriesType.dailyCheck => LocaleKeys.enum_seriesType_dailyCheck_title.tr(),
      SeriesType.dailyLife => LocaleKeys.enum_seriesType_dailyLife_title.tr(),
      SeriesType.habit => LocaleKeys.enum_seriesType_habit_title.tr(),
      SeriesType.custom => LocaleKeys.enum_seriesType_custom_title.tr(),
    };
  }

  static String infoOf(SeriesType seriesType) {
    return switch (seriesType) {
      SeriesType.bloodPressure => LocaleKeys.enum_seriesType_bloodPressure_info.tr(),
      SeriesType.dailyCheck => LocaleKeys.enum_seriesType_dailyCheck_info.tr(),
      SeriesType.dailyLife => LocaleKeys.enum_seriesType_dailyLife_info.tr(),
      SeriesType.habit => LocaleKeys.enum_seriesType_habit_info.tr(),
      SeriesType.custom => LocaleKeys.enum_seriesType_custom_info.tr(),
    };
  }
}
