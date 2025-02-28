import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  static String? compose(String? msgId, AppLocalizations t) {
    return switch (msgId) {
      // blood pressure
      bloodPressureSeriesItemTitleDiastolic => t.bloodPressureSeriesItemTitleDiastolic,
      bloodPressureSeriesItemTitleSystolic => t.bloodPressureSeriesItemTitleSystolic,
      bloodPressureTableColumnTitleDate => t.bloodPressureTableColumnTitleDate,
      bloodPressureTableColumnTitleMorning => t.bloodPressureTableColumnTitleMorning,
      bloodPressureTableColumnTitleMidday => t.bloodPressureTableColumnTitleMidday,
      bloodPressureTableColumnTitleEvening => t.bloodPressureTableColumnTitleEvening,
      // date
      commonsDateShortWeekdayMonday => t.commonsDateShortWeekdayMonday,
      commonsDateShortWeekdayTuesday => t.commonsDateShortWeekdayTuesday,
      commonsDateShortWeekdayWednesday => t.commonsDateShortWeekdayWednesday,
      commonsDateShortWeekdayThursday => t.commonsDateShortWeekdayThursday,
      commonsDateShortWeekdayFriday => t.commonsDateShortWeekdayFriday,
      commonsDateShortWeekdaySaturday => t.commonsDateShortWeekdaySaturday,
      commonsDateShortWeekdaySunday => t.commonsDateShortWeekdaySunday,
      _ => null, // default
    };
  }

  static List<String> composeShortWeekdays(AppLocalizations t) {
    return [
      compose(commonsDateShortWeekdayMonday, t)!,
      compose(commonsDateShortWeekdayTuesday, t)!,
      compose(commonsDateShortWeekdayWednesday, t)!,
      compose(commonsDateShortWeekdayThursday, t)!,
      compose(commonsDateShortWeekdayFriday, t)!,
      compose(commonsDateShortWeekdaySaturday, t)!,
      compose(commonsDateShortWeekdaySunday, t)!,
    ];
  }
}
