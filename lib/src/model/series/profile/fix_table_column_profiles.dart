import '../../../util/i18n.dart';
import 'table_column_profile.dart';

class FixTableColumnProfiles {
  static final TableColumnProfile tableColumnProfileBloodPressure = TableColumnProfile(columns: [
    TableColumn(minWidth: 80, title: '-', msgId: I18N.bloodPressureTableColumnTitleDate),
    TableColumn(minWidth: 80, title: '-', msgId: I18N.bloodPressureTableColumnTitleMorning),
    TableColumn(minWidth: 80, title: '-', msgId: I18N.bloodPressureTableColumnTitleMidday),
    TableColumn(minWidth: 80, title: '-', msgId: I18N.bloodPressureTableColumnTitleEvening),
  ]);
}
