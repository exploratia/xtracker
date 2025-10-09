import '../../../generated/locale_keys.g.dart';
import 'column_profile.dart';
import 'fix_column_profile_type.dart';

class FixColumnProfile extends ColumnProfile {
  FixColumnProfile(this.type, {required super.columns});

  final FixColumnProfileType type;

  String get displayName {
    return type.displayName;
  }

  @override
  String toString() {
    return 'FixColumnProfile{name: $type, ${super.toString()}}';
  }

  static final FixColumnProfile columnProfileDateMorningMiddayEvening = FixColumnProfile(
    FixColumnProfileType.dateMorningMiddayEvening,
    columns: [
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_date_date),
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_date_morning),
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_date_midday),
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_date_evening),
    ],
  );
  static final FixColumnProfile columnProfileDateTimeValue = FixColumnProfile(
    FixColumnProfileType.dateTimeValue,
    columns: [
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_date_date),
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_date_time),
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_label_value),
    ],
  );
  static final FixColumnProfile columnProfileDateDayRange = FixColumnProfile(
    FixColumnProfileType.dateDayRange,
    columns: [
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_date_date),
      ColumnDef(minWidth: 160, title: '-', msgId: LocaleKeys.commons_columnProfile_columns_dayRange),
    ],
  );
  static final FixColumnProfile columnProfileDateHourlyOverview = FixColumnProfile(
    FixColumnProfileType.dateHourlyOverview,
    columns: [
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_date_date),
      ColumnDef(minWidth: 160, title: '-', msgId: LocaleKeys.commons_columnProfile_columns_hourlyOverview),
    ],
  );

  static final FixColumnProfile columnProfileDateWeekdays = FixColumnProfile(
    FixColumnProfileType.dateWeekdays,
    columns: [
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_date_date),
      ...[
        LocaleKeys.commons_date_shortWeekday_monday,
        LocaleKeys.commons_date_shortWeekday_tuesday,
        LocaleKeys.commons_date_shortWeekday_wednesday,
        LocaleKeys.commons_date_shortWeekday_thursday,
        LocaleKeys.commons_date_shortWeekday_friday,
        LocaleKeys.commons_date_shortWeekday_saturday,
        LocaleKeys.commons_date_shortWeekday_sunday,
      ].map((msgId) => ColumnDef(minWidth: 30, title: '-', msgId: msgId, disablePadding: true)),
    ],
  );

  static final FixColumnProfile columnProfileDateMonthDays = FixColumnProfile(
    FixColumnProfileType.dateMonthDays,
    columns: [
      ColumnDef(minWidth: 80, title: '-', msgId: LocaleKeys.commons_date_date),
      ...List.generate(31, (i) => ColumnDef(minWidth: 16, title: '${i % 2 == 0 ? i + 1 : ''}', msgId: null, disablePadding: true)),
    ],
  );

  static FixColumnProfile? resolveByType(FixColumnProfileType? type) {
    if (type == null) return null;
    return switch (type) {
      FixColumnProfileType.dateMorningMiddayEvening => columnProfileDateMorningMiddayEvening,
      FixColumnProfileType.dateTimeValue => columnProfileDateTimeValue,
      FixColumnProfileType.dateDayRange => columnProfileDateDayRange,
      FixColumnProfileType.dateHourlyOverview => columnProfileDateHourlyOverview,
      FixColumnProfileType.dateWeekdays => columnProfileDateWeekdays,
      FixColumnProfileType.dateMonthDays => columnProfileDateMonthDays,
    };
  }

  static bool isMultiValueDayProfile(FixColumnProfile fixColumnProfile) =>
      fixColumnProfile == FixColumnProfile.columnProfileDateDayRange || fixColumnProfile == FixColumnProfile.columnProfileDateHourlyOverview;
}
