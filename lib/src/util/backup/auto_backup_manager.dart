import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../logging/flutter_simple_logging.dart';
import 'backup_file_name.dart';
import 'dropbox_backup_service.dart';

typedef TemporaryDirectoryProvider = Future<Directory> Function();

/// Immutable outcome of an automatic backup attempt.
class BackupResult {
  const BackupResult.success() : success = true, error = null, stackTrace = null;

  const BackupResult.failure(this.error, this.stackTrace) : success = false;

  final bool success;
  final Object? error;
  final StackTrace? stackTrace;
}

/// Orchestrates backup serialization and upload without UI dependencies.
class AutoBackupManager {
  AutoBackupManager({required BackupUploader uploader, TemporaryDirectoryProvider? temporaryDirectoryProvider})
    : _uploader = uploader,
      _temporaryDirectoryProvider = temporaryDirectoryProvider ?? getTemporaryDirectory;

  final BackupUploader _uploader;
  final TemporaryDirectoryProvider _temporaryDirectoryProvider;

  /// Returns whether a backup is due at [now].
  bool isBackupDue(DateTime? nextBackupDate, DateTime now) {
    if (nextBackupDate == null) return true;
    final scheduledDay = DateTime(nextBackupDate.year, nextBackupDate.month, nextBackupDate.day);
    final currentDay = DateTime(now.year, now.month, now.day);
    return !currentDay.isBefore(scheduledDay);
  }

  /// Writes [backupJson] temporarily and uploads it to the Dropbox app folder.
  Future<BackupResult> performBackup({required Map<String, dynamic> backupJson, required DateTime now}) async {
    File? temporaryFile;
    try {
      final fileName = BackupFileName.build(now);
      final temporaryDirectory = await _temporaryDirectoryProvider();
      temporaryFile = File('${temporaryDirectory.path}${Platform.pathSeparator}$fileName');
      await temporaryFile.writeAsString(jsonEncode(backupJson), encoding: utf8, flush: true);
      SimpleLogging.i('Automatic backup file created: $fileName.');

      await _uploader.uploadBackup(temporaryFile.path, '/$fileName');
      return const BackupResult.success();
    } catch (error, stackTrace) {
      SimpleLogging.w('Automatic backup failed.', error: error, stackTrace: stackTrace);
      return BackupResult.failure(error, stackTrace);
    } finally {
      if (temporaryFile != null && await temporaryFile.exists()) {
        try {
          await temporaryFile.delete();
        } catch (error, stackTrace) {
          SimpleLogging.w('Could not remove temporary backup file.', error: error, stackTrace: stackTrace);
        }
      }
    }
  }
}
