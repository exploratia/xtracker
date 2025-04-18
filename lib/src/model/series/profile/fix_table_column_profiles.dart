import '../../../util/i18n.dart';
import 'table_column_profile.dart';

class FixTableColumnProfiles {
  static final TableColumnProfile tableColumnProfileDateMorningMiddayEvening = TableColumnProfile(columns: [
    TableColumn(minWidth: 80, title: '-', msgId: I18N.commonsDateDate),
    TableColumn(minWidth: 80, title: '-', msgId: I18N.commonsDateMorning),
    TableColumn(minWidth: 80, title: '-', msgId: I18N.commonsDateMidday),
    TableColumn(minWidth: 80, title: '-', msgId: I18N.commonsDateEvening),
  ]);
}
