import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';

enum FixColumnProfileType {
  dateMorningMiddayEvening("Date|Morning|Midday|Evening"),
  dateTimeValue("Date|Time|Value"),
  dateDayRange("Date|DayRange"),
  dateHourlyOverview("Date|HourlyOverview"),
  dateWeekdays("Date|...Weekdays"),
  dateMonthDays("Date|...MonthDays");

  final String typeName;

  const FixColumnProfileType(this.typeName);

  String get displayName => displayNameOf(this);

  static String displayNameOf(FixColumnProfileType type) {
    return switch (type) {
      FixColumnProfileType.dateMorningMiddayEvening => LocaleKeys.commons_columnProfile_name_dateMorningMiddayEvening.tr(),
      FixColumnProfileType.dateTimeValue => LocaleKeys.commons_columnProfile_name_dateTimeValue.tr(),
      FixColumnProfileType.dateDayRange => LocaleKeys.commons_columnProfile_name_dateDayRange.tr(),
      FixColumnProfileType.dateHourlyOverview => LocaleKeys.commons_columnProfile_name_dateHourlyOverview.tr(),
      FixColumnProfileType.dateWeekdays => LocaleKeys.commons_columnProfile_name_dateWeekdays.tr(),
      FixColumnProfileType.dateMonthDays => LocaleKeys.commons_columnProfile_name_dateMonthDays.tr(),
    };
  }

  static FixColumnProfileType? resolveByTypeName(String? typeName) {
    return FixColumnProfileType.values.where((element) => element.typeName == typeName).firstOrNull;
  }
}
