import '../../util/i18n.dart';
import 'column_profile.dart';

class FixColumnProfile {
  static final ColumnProfile columnProfileDateMorningMiddayEvening = ColumnProfile(columns: [
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateDate),
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateMorning),
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateMidday),
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateEvening),
  ]);
  static final ColumnProfile columnProfileDateTimeValue = ColumnProfile(columns: [
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateDate),
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateTime),
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsLabelValue),
  ]);

  static final ColumnProfile columnProfileDateWeekdays = ColumnProfile(columns: [
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
  ]);

  static final ColumnProfile columnProfileDateMonthDays = ColumnProfile(columns: [
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateDate),
    ...List.generate(31, (i) => ColumnDef(minWidth: 16, title: '${i % 2 == 0 ? i + 1 : ''}', msgId: null, disablePadding: true))
  ]);
}
