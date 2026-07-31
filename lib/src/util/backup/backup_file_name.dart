import '../date_time_utils.dart';

/// Defines file names for automatic Dropbox backups.
class BackupFileName {
  static const prefix = 'xtracker_backup_';
  static const extension = '.json';

  /// Builds a file name such as `xtracker_backup_20260731.json`.
  static String build(DateTime dateTime) {
    return '$prefix${DateTimeUtils.formatBackupDate(dateTime)}$extension';
  }
}
