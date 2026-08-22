import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../util/backup/auto_backup_manager.dart';
import '../../util/backup/dropbox_backup_service.dart';
import '../../util/dialogs.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../administration/settings/settings_controller.dart';
import '../controls/overlay/animated_backup_overlay.dart';

/// Runs a Dropbox backup with the shared overlay and user feedback.
class AutoBackupRunner {
  /// Executes a backup and updates its latest and next execution dates.
  static Future<bool> run(
    BuildContext context,
    SettingsController settingsController, {
    required Future<Map<String, dynamic>> Function() buildBackupJson,
    DropboxBackupService? backupService,
  }) async {
    final now = DateTime.now();
    final service = backupService ?? DropboxBackupService.instance;
    final manager = AutoBackupManager(uploader: service);
    OverlayEntry? overlay;
    var succeeded = false;
    var feedbackKey = LocaleKeys.autoBackup_snackbar_failure;
    try {
      if (!await service.hasInternetConnection()) {
        feedbackKey = LocaleKeys.autoBackup_snackbar_noInternet;
        SimpleLogging.w('Dropbox backup skipped because no internet connection is available.');
        return false;
      }
      if (!await service.isAuthorized()) {
        SimpleLogging.w('Dropbox backup skipped because Dropbox is not authorized.');
        return false;
      }
      if (!context.mounted) return false;

      SimpleLogging.i('Dropbox backup started.');
      overlay = AnimatedBackupOverlay.show(context);
      final backupJson = await buildBackupJson();
      if (!context.mounted) return false;
      final result = await manager.performBackup(backupJson: backupJson, now: now);
      if (!result.success) {
        if (result.error is TimeoutException) feedbackKey = LocaleKeys.autoBackup_snackbar_timeout;
        return false;
      }

      await settingsController.updateAutoBackupDate(now);
      await settingsController.updateAutoBackupNextDate(
        DateTime(now.year, now.month, now.day + settingsController.autoBackupIntervalDays),
      );
      succeeded = true;
      return true;
    } catch (error, stackTrace) {
      if (error is TimeoutException) feedbackKey = LocaleKeys.autoBackup_snackbar_timeout;
      SimpleLogging.w('Dropbox backup failed.', error: error, stackTrace: stackTrace);
      return false;
    } finally {
      overlay?.remove();
      if (!succeeded) {
        try {
          await settingsController.scheduleAutoBackupRetry(now);
        } catch (error, stackTrace) {
          SimpleLogging.w('Could not schedule Dropbox backup retry.', error: error, stackTrace: stackTrace);
        }
      }
      if (context.mounted) {
        if (succeeded) {
          Dialogs.showSnackBar(LocaleKeys.autoBackup_snackbar_success.tr(), context);
        } else {
          Dialogs.showSnackBarWarning(feedbackKey.tr(), context);
        }
      }
    }
  }
}
