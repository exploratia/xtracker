import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/navigation/navigation_item.dart';
import '../../widgets/administration/settings/settings_controller.dart';
import '../../widgets/administration/settings/settings_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/responsive/screen_builder.dart';

class SettingsScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.settings_outlined),
    routeName: '/settings',
    titleBuilder: (t) => t.settingsTitle,
  );

  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(context,
          // TODO back instead of Drawer
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(navItem.titleBuilder(t))),
      bodyBuilder: (context) => SettingsView(controller: controller),
    );
  }
}
