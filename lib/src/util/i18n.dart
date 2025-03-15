import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';

class I18N {
  static const String bloodPressureSeriesItemTitleDiastolic = 'bloodPressureSeriesItemTitleDiastolic';
  static const String bloodPressureSeriesItemTitleSystolic = 'bloodPressureSeriesItemTitleSystolic';
  static const String bloodPressureTableColumnTitleDate = 'bloodPressureTableColumnTitleDate';
  static const String bloodPressureTableColumnTitleMorning = 'bloodPressureTableColumnTitleMorning';
  static const String bloodPressureTableColumnTitleMidday = 'bloodPressureTableColumnTitleMidday';
  static const String bloodPressureTableColumnTitleEvening = 'bloodPressureTableColumnTitleEvening';

  static const String commonsDateShortWeekdayMonday = 'commonsDateShortWeekdayMonday';
  static const String commonsDateShortWeekdayTuesday = 'commonsDateShortWeekdayTuesday';
  static const String commonsDateShortWeekdayWednesday = 'commonsDateShortWeekdayWednesday';
  static const String commonsDateShortWeekdayThursday = 'commonsDateShortWeekdayThursday';
  static const String commonsDateShortWeekdayFriday = 'commonsDateShortWeekdayFriday';
  static const String commonsDateShortWeekdaySaturday = 'commonsDateShortWeekdaySaturday';
  static const String commonsDateShortWeekdaySunday = 'commonsDateShortWeekdaySunday';

  static String? compose(String? msgId) {
    return switch (msgId) {
      // blood pressure
      bloodPressureSeriesItemTitleDiastolic => LocaleKeys.bloodPressure_seriesItem_title_diastolic.tr(),
      bloodPressureSeriesItemTitleSystolic => LocaleKeys.bloodPressure_seriesItem_title_systolic.tr(),
      bloodPressureTableColumnTitleDate => LocaleKeys.bloodPressure_table_columns_date.tr(),
      bloodPressureTableColumnTitleMorning => LocaleKeys.bloodPressure_table_columns_morning.tr(),
      bloodPressureTableColumnTitleMidday => LocaleKeys.bloodPressure_table_columns_midday.tr(),
      bloodPressureTableColumnTitleEvening => LocaleKeys.bloodPressure_table_columns_evening.tr(),
      // date
      commonsDateShortWeekdayMonday => LocaleKeys.commons_date_shortWeekday_monday.tr(),
      commonsDateShortWeekdayTuesday => LocaleKeys.commons_date_shortWeekday_tuesday.tr(),
      commonsDateShortWeekdayWednesday => LocaleKeys.commons_date_shortWeekday_wednesday.tr(),
      commonsDateShortWeekdayThursday => LocaleKeys.commons_date_shortWeekday_thursday.tr(),
      commonsDateShortWeekdayFriday => LocaleKeys.commons_date_shortWeekday_friday.tr(),
      commonsDateShortWeekdaySaturday => LocaleKeys.commons_date_shortWeekday_saturday.tr(),
      commonsDateShortWeekdaySunday => LocaleKeys.commons_date_shortWeekday_sunday.tr(),
      _ => null, // default
    };
  }

  static List<String> composeShortWeekdays() {
    return [
      compose(commonsDateShortWeekdayMonday)!,
      compose(commonsDateShortWeekdayTuesday)!,
      compose(commonsDateShortWeekdayWednesday)!,
      compose(commonsDateShortWeekdayThursday)!,
      compose(commonsDateShortWeekdayFriday)!,
      compose(commonsDateShortWeekdaySaturday)!,
      compose(commonsDateShortWeekdaySunday)!,
    ];
  }
}
