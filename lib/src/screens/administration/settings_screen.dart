import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/administration/settings/settings_controller.dart';
import '../../widgets/administration/settings/settings_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: GradientAppBar.build(
        context,
        title: Text(t!.settingsTitle),
      ),
      body: SettingsView(controller: controller),
    );
  }
}
