import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/navigation/navigation_item.dart';
import '../../widgets/administration/logging/log_settings_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/responsive/screen_builder.dart';

class LogSettingsScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.settings_outlined),
    routeName: '/log_settings_screen',
    titleBuilder: (t) => t.logSettingsTitle,
  );

  const LogSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) =>
          GradientAppBar.build(context, title: Text(navItem.titleBuilder(t))),
      bodyBuilder: (context) => const LogSettingsView(),
    );
  }
}
