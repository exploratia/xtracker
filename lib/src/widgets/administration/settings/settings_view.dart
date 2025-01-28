import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../card/expandable_settings_card.dart';
import '../../text/overflow_text.dart';
import './settings_controller.dart';
import 'device_storage_view.dart';
import 'general_settings_view.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Column(
      children: [
        ExpandableSettingsCard(
            title: OverflowText(t!.settingsGeneralCardTitle,
                style: Theme.of(context).textTheme.titleLarge),
            content: GeneralSettingsView(controller: controller)),
        ExpandableSettingsCard(
            title: OverflowText(t.settingsDeviceStorageTitle,
                style: Theme.of(context).textTheme.titleLarge),
            content: DeviceStorageView()),
      ],
    );
  }
}
