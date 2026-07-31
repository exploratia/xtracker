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
    bool showAuthorizationFailure = true,
  }) async {
    if (!await DropboxBackupService.instance.isAuthorized()) {
      SimpleLogging.w('Dropbox backup skipped because Dropbox is not authorized.');
      if (showAuthorizationFailure && context.mounted) {
        Dialogs.showSnackBarWarning(LocaleKeys.autoBackup_snackbar_failure.tr(), context);
      }
      return false;
    }
    if (!context.mounted) return false;

    final now = DateTime.now();
    final manager = AutoBackupManager(uploader: DropboxBackupService.instance);
    SimpleLogging.i('Dropbox backup started.');
    final overlay = AnimatedBackupOverlay.show(context);
    var succeeded = false;
    try {
      final backupJson = await buildBackupJson();
      if (!context.mounted) return false;
      final result = await manager.performBackup(backupJson: backupJson, now: now);
      if (!result.success) return false;

      await settingsController.updateAutoBackupDate(now);
      await settingsController.updateAutoBackupNextDate(
        DateTime(now.year, now.month, now.day + settingsController.autoBackupIntervalDays),
      );
      succeeded = true;
      return true;
    } catch (error, stackTrace) {
      SimpleLogging.w('Dropbox backup failed.', error: error, stackTrace: stackTrace);
      return false;
    } finally {
      overlay.remove();
      if (context.mounted) {
        if (succeeded) {
          Dialogs.showSnackBar(LocaleKeys.autoBackup_snackbar_success.tr(), context);
        } else {
          Dialogs.showSnackBarWarning(LocaleKeys.autoBackup_snackbar_failure.tr(), context);
        }
      }
    }
  }
}
