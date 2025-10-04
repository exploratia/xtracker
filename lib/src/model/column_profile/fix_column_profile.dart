import '../../util/i18n.dart';
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
      ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateDate),
      ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateMorning),
      ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateMidday),
      ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateEvening),
    ],
  );
  static final FixColumnProfile columnProfileDateTimeValue = FixColumnProfile(
    FixColumnProfileType.dateTimeValue,
    columns: [
      ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateDate),
      ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateTime),
      ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsLabelValue),
    ],
  );

  static final FixColumnProfile columnProfileDateWeekdays = FixColumnProfile(
    FixColumnProfileType.dateWeekdays,
    columns: [
      ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateDate),
      ...[
        I18N.commonsDateShortWeekdayMonday,
        I18N.commonsDateShortWeekdayTuesday,
        I18N.commonsDateShortWeekdayWednesday,
        I18N.commonsDateShortWeekdayThursday,
        I18N.commonsDateShortWeekdayFriday,
        I18N.commonsDateShortWeekdaySaturday,
        I18N.commonsDateShortWeekdaySunday,
      ].map((msgId) => ColumnDef(minWidth: 30, title: '-', msgId: msgId, disablePadding: true)),
    ],
  );

  static final FixColumnProfile columnProfileDateMonthDays = FixColumnProfile(
    FixColumnProfileType.dateMonthDays,
    columns: [
      ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateDate),
      ...List.generate(31, (i) => ColumnDef(minWidth: 16, title: '${i % 2 == 0 ? i + 1 : ''}', msgId: null, disablePadding: true)),
    ],
  );

  static FixColumnProfile? resolveByType(FixColumnProfileType? type) {
    return [
      columnProfileDateMorningMiddayEvening,
      columnProfileDateTimeValue,
      columnProfileDateMonthDays,
      columnProfileDateWeekdays,
    ].where((cp) => cp.type == type).firstOrNull;
  }
}
