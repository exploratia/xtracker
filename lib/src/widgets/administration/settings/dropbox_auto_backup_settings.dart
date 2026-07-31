import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/backup/dropbox_backup_service.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/theme_utils.dart';
import 'settings_controller.dart';

/// Mobile-only controls for Dropbox automatic backups.
class DropboxAutoBackupSettings extends StatefulWidget {
  const DropboxAutoBackupSettings({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<DropboxAutoBackupSettings> createState() => _DropboxAutoBackupSettingsState();
}

class _DropboxAutoBackupSettingsState extends State<DropboxAutoBackupSettings> with WidgetsBindingObserver {
  late final TextEditingController _intervalController;
  bool _authorizing = false;
  bool _authorizationActivityOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _intervalController = TextEditingController(text: widget.controller.autoBackupIntervalDays.toString());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intervalController.dispose();
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

  Future<void> _saveInterval(String value) async {
    final parsedValue = int.tryParse(value) ?? SettingsController.defaultAutoBackupIntervalDays;
    final validatedValue = parsedValue.clamp(
      SettingsController.minAutoBackupIntervalDays,
      SettingsController.maxAutoBackupIntervalDays,
    );
    _intervalController.text = validatedValue.toString();
    await widget.controller.updateAutoBackupIntervalDays(validatedValue);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.controller.autoBackupEnabled;
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
                    SizedBox(
                      width: 88,
                      child: TextFormField(
                        controller: _intervalController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textAlign: TextAlign.end,
                        onFieldSubmitted: _saveInterval,
                        onTapOutside: (_) {
                          _saveInterval(_intervalController.text);
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                    ),
                  ],
                ),
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
