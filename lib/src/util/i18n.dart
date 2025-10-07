import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';

class I18N {
  static const String bloodPressureSeriesItemTitleDiastolic = 'bloodPressureSeriesItemTitleDiastolic';
  static const String bloodPressureSeriesItemTitleSystolic = 'bloodPressureSeriesItemTitleSystolic';

  static const String commonsColumnDayRange = 'commonsColumnDayRange';
  static const String commonsColumnHourlyOverview = 'commonsColumnHourlyOverview';
  static const String commonsDateDate = 'commonsDateDate';
  static const String commonsDateTime = 'commonsDateTime';
  static const String commonsDateMorning = 'commonsDateMorning';
  static const String commonsDateMidday = 'commonsDateMidday';
  static const String commonsDateEvening = 'commonsDateEvening';
  static const String commonsDateShortWeekdayMonday = 'commonsDateShortWeekdayMonday';
  static const String commonsDateShortWeekdayTuesday = 'commonsDateShortWeekdayTuesday';
  static const String commonsDateShortWeekdayWednesday = 'commonsDateShortWeekdayWednesday';
  static const String commonsDateShortWeekdayThursday = 'commonsDateShortWeekdayThursday';
  static const String commonsDateShortWeekdayFriday = 'commonsDateShortWeekdayFriday';
  static const String commonsDateShortWeekdaySaturday = 'commonsDateShortWeekdaySaturday';
  static const String commonsDateShortWeekdaySunday = 'commonsDateShortWeekdaySunday';

  static const String commonsLabelValue = 'commonsLabelValue';

  static String? compose(String? msgId) {
    return switch (msgId) {
      // blood pressure
      bloodPressureSeriesItemTitleDiastolic => LocaleKeys.seriesValue_bloodPressure_label_diastolic.tr(),
      bloodPressureSeriesItemTitleSystolic => LocaleKeys.seriesValue_bloodPressure_label_systolic.tr(),
      // column profile
      commonsColumnDayRange => LocaleKeys.commons_columnProfile_columns_dayRange.tr(),
      commonsColumnHourlyOverview => LocaleKeys.commons_columnProfile_columns_hourlyOverview.tr(),
      // date
      commonsDateDate => LocaleKeys.commons_date_date.tr(),
      commonsDateTime => LocaleKeys.commons_date_time.tr(),
      commonsDateMorning => LocaleKeys.commons_date_morning.tr(),
      commonsDateMidday => LocaleKeys.commons_date_midday.tr(),
      commonsDateEvening => LocaleKeys.commons_date_evening.tr(),
      commonsDateShortWeekdayMonday => LocaleKeys.commons_date_shortWeekday_monday.tr(),
      commonsDateShortWeekdayTuesday => LocaleKeys.commons_date_shortWeekday_tuesday.tr(),
      commonsDateShortWeekdayWednesday => LocaleKeys.commons_date_shortWeekday_wednesday.tr(),
      commonsDateShortWeekdayThursday => LocaleKeys.commons_date_shortWeekday_thursday.tr(),
      commonsDateShortWeekdayFriday => LocaleKeys.commons_date_shortWeekday_friday.tr(),
      commonsDateShortWeekdaySaturday => LocaleKeys.commons_date_shortWeekday_saturday.tr(),
      commonsDateShortWeekdaySunday => LocaleKeys.commons_date_shortWeekday_sunday.tr(),
      commonsLabelValue => LocaleKeys.commons_label_value.tr(),
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
