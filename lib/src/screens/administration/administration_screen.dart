import 'package:flutter/material.dart';

import '../../model/navigation/main_navigation_item.dart';
import '../../util/globals.dart';
import '../../widgets/administration/administration_view.dart';
import '../../widgets/layout/gradient_app_bar.dart';
import '../../widgets/navigation/app_bottom_navigation_bar.dart';
import '../../widgets/navigation/app_drawer.dart';
import '../../widgets/navigation/app_navigation_rail.dart';
import '../../widgets/responsive/screen_builder.dart';

class AdministrationScreen extends StatelessWidget {
  static MainNavigationItem mainNavigationItem = MainNavigationItem(
      icon: const Icon(Icons.more_horiz),
      routeName: '/administration_screen',
      titleBuilder: (t) => t.administrationTitle,
      screenBuilder: () => const AdministrationScreen());

  const AdministrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder(
        appBarBuilder: (context) => GradientAppBar.build(
              context,
              title: SizedBox(
                width: 30,
                child: Image.asset(
                  Globals.assetImgAppLogoWhite,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        bottomNavigationBarBuilder: (context) => const AppBottomNavigationBar(),
        navigationRailBuilder: (context) => const AppNavigationRail(),
        drawerBuilder: (context) => const AppDrawer(),
        bodyBuilder: (context) => const AdministrationView());
  }
}
