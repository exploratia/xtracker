import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class I18N {
  static const String bloodPressureSeriesItemTitleDiastolic = 'bloodPressureSeriesItemTitleDiastolic';
  static const String bloodPressureSeriesItemTitleSystolic = 'bloodPressureSeriesItemTitleSystolic';
  static const String bloodPressureTableColumnTitleDate = 'bloodPressureTableColumnTitleDate';
  static const String bloodPressureTableColumnTitleMorning = 'bloodPressureTableColumnTitleMorning';
  static const String bloodPressureTableColumnTitleMidday = 'bloodPressureTableColumnTitleMidday';
  static const String bloodPressureTableColumnTitleEvening = 'bloodPressureTableColumnTitleEvening';

  static String? compose(String? msgId, AppLocalizations t) {
    return switch (msgId) {
      bloodPressureSeriesItemTitleDiastolic => t.bloodPressureSeriesItemTitleDiastolic,
      bloodPressureSeriesItemTitleSystolic => t.bloodPressureSeriesItemTitleSystolic,
      bloodPressureTableColumnTitleDate => t.bloodPressureTableColumnTitleDate,
      bloodPressureTableColumnTitleMorning => t.bloodPressureTableColumnTitleMorning,
      bloodPressureTableColumnTitleMidday => t.bloodPressureTableColumnTitleMidday,
      bloodPressureTableColumnTitleEvening => t.bloodPressureTableColumnTitleEvening,
      _ => null, // default
    };
  }
}
