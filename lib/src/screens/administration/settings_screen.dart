import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/navigation_item.dart';
import '../../widgets/administration/settings/settings_controller.dart';
import '../../widgets/administration/settings/settings_view.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/responsive/screen_builder.dart';

class SettingsScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    iconData: Icons.settings_outlined,
    routeName: '/settings',
    titleBuilder: () => LocaleKeys.settings_title.tr(),
  );

  const SettingsScreen({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      // special case in settings screen. Wallpaper has to be always false!
      // Otherwise the full screen is rebuild (because of the stack) and the settings card collapses.
      // SettingsView has the stack additionally but always.
      showWallpaper: false /* settingsController.showWallpaper */,
      appBarBuilder: (context) => GradientAppBar.build(
        context,
        addLeadingBackBtn: true,
        title: Text(
          navItem.titleBuilder(),
        ),
      ),
      bodyBuilder: (context) => SettingsView(settingsController: settingsController),
    );
  }
}
