import 'package:flutter/material.dart';

import '../../util/backup/auto_backup_manager.dart';
import '../../util/backup/dropbox_backup_service.dart';
import '../../util/series/series_import_export.dart';
import '../administration/settings/settings_controller.dart';
import 'auto_backup_runner.dart';

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

    await AutoBackupRunner.run(
      context,
      widget.settingsController,
      buildBackupJson: () => SeriesImportExport.buildAllSeriesBackupJson(context),
      showAuthorizationFailure: false,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
