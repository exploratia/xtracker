import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/main_navigation_item.dart';
import '../../widgets/administration/administration_view.dart';
import '../../widgets/administration/settings/settings_controller.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/responsive/screen_builder.dart';

class AdministrationScreen extends StatelessWidget {
  static MainNavigationItem navItem = MainNavigationItem(
    iconData: Icons.more_horiz,
    routeName: '/administration_screen',
    titleBuilder: () => LocaleKeys.administration_nav_title.tr(),
    tooltipBuilder: () => LocaleKeys.administration_nav_tooltip.tr(),
  );

  final SettingsController settingsController;

  const AdministrationScreen({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      showWallpaper: settingsController.showWallpaper,
      appBarBuilder: (context) => GradientAppBar.build(
        context,
        addLeadingBackBtn: true,
        title: Text(
          navItem.titleBuilder(),
        ),
      ),
      bodyBuilder: (context) => const AdministrationView(),
    );
  }
}
