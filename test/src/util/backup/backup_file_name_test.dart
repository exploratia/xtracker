import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/backup/backup_file_name.dart';

void main() {
  test('builds the required date-based backup file name', () {
    expect(BackupFileName.build(DateTime(2026, 7, 3)), 'xtracker_backup_20260703.json');
  });
}
