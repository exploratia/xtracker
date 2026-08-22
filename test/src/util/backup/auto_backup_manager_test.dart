import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/backup/auto_backup_manager.dart';
import 'package:xtracker/src/util/backup/dropbox_backup_service.dart';

void main() {
  group('isBackupDue', () {
    final manager = AutoBackupManager(uploader: _RecordingUploader());
    final now = DateTime(2026, 7, 31, 12);

    test('is due without a next date', () {
      expect(manager.isBackupDue(null, now), isTrue);
    });

    test('is not due before the next calendar date', () {
      expect(manager.isBackupDue(DateTime(2026, 8, 1), now), isFalse);
    });

    test('is due throughout the scheduled calendar date', () {
      expect(manager.isBackupDue(DateTime(2026, 7, 31), DateTime(2026, 7, 31, 0, 1)), isTrue);
      expect(manager.isBackupDue(DateTime(2026, 7, 31, 23, 59), DateTime(2026, 7, 31, 0, 1)), isTrue);
    });

    test('is due after the scheduled calendar date', () {
      expect(manager.isBackupDue(DateTime(2026, 7, 30, 23, 59), now), isTrue);
    });
  });

  test('writes, uploads, and removes the temporary backup file', () async {
    final directory = await Directory.systemTemp.createTemp('xtracker_backup_test_');
    addTearDown(() => directory.delete(recursive: true));
    final uploader = _RecordingUploader();
    final manager = AutoBackupManager(
      uploader: uploader,
      temporaryDirectoryProvider: () async => directory,
    );

    final result = await manager.performBackup(
      backupJson: <String, dynamic>{'type': 'multiSeriesExport', 'series': <Object>[]},
      now: DateTime(2026, 7, 31),
    );

    expect(result.success, isTrue);
    expect(uploader.dropboxPath, '/xtracker_backup_20260731_000000.json');
    expect(jsonDecode(uploader.uploadedContent!), containsPair('type', 'multiSeriesExport'));
    expect(directory.listSync(), isEmpty);
  });

  test('returns a failure and still removes the temporary file', () async {
    final directory = await Directory.systemTemp.createTemp('xtracker_backup_test_');
    addTearDown(() => directory.delete(recursive: true));
    final manager = AutoBackupManager(
      uploader: _RecordingUploader(fail: true),
      temporaryDirectoryProvider: () async => directory,
    );

    final result = await manager.performBackup(backupJson: <String, dynamic>{}, now: DateTime(2026, 7, 31));

    expect(result.success, isFalse);
    expect(result.error, isA<StateError>());
    expect(directory.listSync(), isEmpty);
  });
}

class _RecordingUploader implements BackupUploader {
  _RecordingUploader({this.fail = false});

  final bool fail;
  String? dropboxPath;
  String? uploadedContent;

  @override
  Future<void> uploadBackup(String localFilePath, String dropboxPath) async {
    if (fail) throw StateError('Upload failed');
    this.dropboxPath = dropboxPath;
    uploadedContent = await File(localFilePath).readAsString();
  }
}
