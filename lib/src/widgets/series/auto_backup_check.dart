import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../util/backup/auto_backup_manager.dart';
import '../../util/backup/dropbox_backup_service.dart';
import '../../util/dialogs.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../../util/series/series_import_export.dart';
import '../administration/settings/settings_controller.dart';
import '../controls/overlay/animated_backup_overlay.dart';

/// Runs the automatic backup check once after startup actions have completed.
class AutoBackupCheck extends StatefulWidget {
  const AutoBackupCheck({
    super.key,
    required this.shouldRun,
    required this.settingsController,
    required this.child,
  });

  final bool shouldRun;
  final SettingsController settingsController;
  final Widget child;

  @override
  State<AutoBackupCheck> createState() => _AutoBackupCheckState();
}

class _AutoBackupCheckState extends State<AutoBackupCheck> {
  bool _hasRun = false;

  @override
  void initState() {
    super.initState();
    _scheduleIfRequested();
  }

  @override
  void didUpdateWidget(covariant AutoBackupCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleIfRequested();
  }

  void _scheduleIfRequested() {
    if (!widget.shouldRun || _hasRun) return;
    _hasRun = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndRun());
  }

  Future<void> _checkAndRun() async {
    if (!mounted || !widget.settingsController.autoBackupEnabled) return;

    final now = DateTime.now();
    final manager = AutoBackupManager(uploader: DropboxBackupService.instance);
    if (!manager.isBackupDue(widget.settingsController.autoBackupNextDate, now)) return;

    if (!await DropboxBackupService.instance.isAuthorized()) {
      SimpleLogging.w('Automatic backup skipped because Dropbox is not authorized.');
      return;
    }
    if (!mounted) return;

    SimpleLogging.i('Automatic backup started.');
    final overlay = AnimatedBackupOverlay.show(context);
    try {
      final backupJson = await SeriesImportExport.buildAllSeriesBackupJson(context);
      final result = await manager.performBackup(backupJson: backupJson, now: now);
      if (!mounted) return;

      if (result.success) {
        final nextDate = now.add(Duration(days: widget.settingsController.autoBackupIntervalDays));
        await widget.settingsController.updateAutoBackupNextDate(nextDate);
        if (mounted) Dialogs.showSnackBar(LocaleKeys.autoBackup_snackbar_success.tr(), context);
      } else {
        Dialogs.showSnackBarWarning(LocaleKeys.autoBackup_snackbar_failure.tr(), context);
      }
    } catch (error, stackTrace) {
      SimpleLogging.w('Automatic backup failed.', error: error, stackTrace: stackTrace);
      if (mounted) Dialogs.showSnackBarWarning(LocaleKeys.autoBackup_snackbar_failure.tr(), context);
    } finally {
      overlay.remove();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
