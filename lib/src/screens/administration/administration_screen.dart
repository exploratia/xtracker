import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/navigation/main_navigation_item.dart';
import '../../widgets/administration/administration_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/responsive/screen_builder.dart';

class AdministrationScreen extends StatelessWidget {
  static MainNavigationItem mainNavigationItem = MainNavigationItem(
      icon: const Icon(Icons.more_horiz),
      routeName: '/administration_screen',
      titleBuilder: (t) => t.administrationNavTitle,
      screenBuilder: () => const AdministrationScreen());

  const AdministrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ScreenBuilder.withStandardNavBuilders(
        appBarBuilder: (context) => GradientAppBar.build(
              context,
              title: Text(t.administrationTitle),
            ),
        bodyBuilder: (context) => const AdministrationView());
  }
}
