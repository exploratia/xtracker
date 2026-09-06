import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/backup/dropbox_backup_service.dart';
import '../../../util/date_time_utils.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/theme_utils.dart';
import '../../controls/layout/drop_down_menu_item_child.dart';
import 'settings_controller.dart';

/// Mobile-only controls for Dropbox automatic backups.
class DropboxAutoBackupSettings extends StatefulWidget {
  const DropboxAutoBackupSettings({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<DropboxAutoBackupSettings> createState() => _DropboxAutoBackupSettingsState();
}

class _DropboxAutoBackupSettingsState extends State<DropboxAutoBackupSettings> with WidgetsBindingObserver {
  bool _authorizing = false;
  bool _authorizationActivityOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_authorizing) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _authorizationActivityOpened = true;
    } else if (state == AppLifecycleState.resumed && _authorizationActivityOpened) {
      _completeAuthorization();
    }
  }

  Future<void> _toggle(bool enabled) async {
    if (enabled) {
      await _authorize();
      return;
    }

    try {
      await DropboxBackupService.instance.unlink();
    } catch (error, stackTrace) {
      SimpleLogging.w('Disabling Dropbox backup failed.', error: error, stackTrace: stackTrace);
      if (mounted) Dialogs.showSnackBarWarning(LocaleKeys.autoBackup_snackbar_authFailure.tr(), context);
    } finally {
      await widget.controller.updateAutoBackupEnabled(false);
    }
  }

  Future<void> _authorize() async {
    setState(() {
      _authorizing = true;
      _authorizationActivityOpened = false;
    });
    try {
      await DropboxBackupService.instance.beginInteractiveAuthorization();
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (await DropboxBackupService.instance.completeInteractiveAuthorization()) {
        await _setAuthorizationSucceeded();
      }
    } catch (error, stackTrace) {
      SimpleLogging.w('Dropbox authorization failed.', error: error, stackTrace: stackTrace);
      await _setAuthorizationFailed();
    }
  }

  Future<void> _completeAuthorization() async {
    if (!_authorizing) return;
    try {
      if (await DropboxBackupService.instance.completeInteractiveAuthorization()) {
        await _setAuthorizationSucceeded();
      } else {
        await _setAuthorizationFailed();
      }
    } catch (error, stackTrace) {
      SimpleLogging.w('Completing Dropbox authorization failed.', error: error, stackTrace: stackTrace);
      await _setAuthorizationFailed();
    }
  }

  Future<void> _setAuthorizationSucceeded() async {
    if (!_authorizing) return;
    await widget.controller.updateAutoBackupEnabled(true);
    if (mounted) setState(() => _authorizing = false);
  }

  Future<void> _setAuthorizationFailed() async {
    try {
      await DropboxBackupService.instance.unlink();
    } catch (error, stackTrace) {
      SimpleLogging.w('Could not clean up failed Dropbox authorization.', error: error, stackTrace: stackTrace);
    }
    await widget.controller.updateAutoBackupEnabled(false);
    if (!mounted) return;
    setState(() => _authorizing = false);
    Dialogs.showSnackBarWarning(LocaleKeys.autoBackup_snackbar_authFailure.tr(), context);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.controller.autoBackupEnabled;
    final nextBackupDate = widget.controller.autoBackupNextDate;
    final nextBackup = nextBackupDate == null ? LocaleKeys.settings_general_info_autoBackupAtNextStart.tr() : DateTimeUtils.formatDate(nextBackupDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: ThemeUtils.defaultPadding),
          value: enabled,
          onChanged: _authorizing ? null : _toggle,
          title: Text(LocaleKeys.settings_general_label_autoBackupEnabled.tr()),
          secondary: _authorizing ? const CircularProgressIndicator() : const Icon(Icons.cloud_upload_outlined),
        ),
        if (enabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: ThemeUtils.verticalSpacing,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(LocaleKeys.settings_general_label_autoBackupIntervalDays.tr())),
                    DropdownButton<int>(
                      key: const Key('settingsAutoBackupIntervalSelect'),
                      borderRadius: ThemeUtils.cardBorderRadius,
                      value: widget.controller.autoBackupIntervalDays,
                      onChanged: (value) async {
                        if (value != null) await widget.controller.updateAutoBackupIntervalDays(value);
                      },
                      items: SettingsController.supportedAutoBackupIntervalDays
                          .map((days) {
                            return DropdownMenuItem<int>(
                              value: days,
                              child: DropDownMenuItemChild(
                                selected: days == widget.controller.autoBackupIntervalDays,
                                child: Text(days.toString()),
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ],
                ),
                Text(LocaleKeys.settings_general_label_autoBackupNextDate.tr(args: [nextBackup])),
                Text(
                  LocaleKeys.settings_general_info_autoBackupNoAutomaticDeletion.tr(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
