import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/settings/settings_controller.dart';
import '../widgets/settings/settings_view.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t!.settingsTitle),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: SettingsView(controller: controller)),
    );
  }
}
