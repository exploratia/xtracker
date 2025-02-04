import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/administration/settings/settings_controller.dart';
import '../../widgets/administration/settings/settings_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/responsive/screen_builder.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  static const icon = Icon(Icons.settings_outlined);
  static String Function(AppLocalizations t) titleBuilder =
      (t) => t.settingsTitle;

  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ScreenBuilder.withStandardNavBuilders(
      routeName: routeName,
      appBarBuilder: (context) =>
          GradientAppBar.build(context, title: Text(titleBuilder(t))),
      bodyBuilder: (context) => SettingsView(controller: controller),
    );
  }
}
