import '../../util/i18n.dart';
import 'column_profile.dart';

class FixColumnProfiles {
  static final ColumnProfile columnProfileDateMorningMiddayEvening = ColumnProfile(columns: [
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateDate),
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateMorning),
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateMidday),
    ColumnDef(minWidth: 80, title: '-', msgId: I18N.commonsDateEvening),
  ]);
}
