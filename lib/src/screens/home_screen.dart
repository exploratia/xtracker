import 'package:flutter/material.dart';

import '../model/navigation/main_navigation_item.dart';
import '../util/globals.dart';
import '../util/navigation/hide_bottom_navigation_bar.dart';
import '../widgets/layout/gradient_app_bar.dart';
import '../widgets/layout/single_child_scroll_view_with_scrollbar.dart';
import '../widgets/navigation/app_bottom_navigation_bar.dart';
import '../widgets/navigation/app_drawer.dart';
import '../widgets/navigation/app_navigation_rail.dart';
import '../widgets/navigation/double_back_to_close.dart';
import '../widgets/responsive/screen_builder.dart';
import './playground_screen.dart';
import 'administration/administration_screen.dart';
import 'administration/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';
  static MainNavigationItem mainNavigationItem = MainNavigationItem(
      icon: const Icon(Icons.home_outlined),
      routeName: routeName,
      titleBuilder: (t) => t.homeTitle,
      screenBuilder: () => const HomeScreen());

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DoubleBackToClose(
      child: ScreenBuilder(
        homeScaffoldKey: Globals.homeScaffoldKey,
        appBarBuilder: (context) => GradientAppBar.build(
          context,
          title: Row(
            children: [
              SizedBox(
                width: 30,
                child: Image.asset(
                  Globals.assetImgAppLogoWhite,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to the settings page. If the user leaves and returns
                // to the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(
                    context, SettingsScreen.routeName);
              },
            ),
          ],
        ),
        bottomNavigationBarBuilder: (context) => const AppBottomNavigationBar(),
        navigationRailBuilder: (context) => const AppNavigationRail(),
        drawerBuilder: (context) => const AppDrawer(),
        bodyBuilder: (context) => SingleChildScrollViewWithScrollbar(
          scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(16), child: Text("Home")),
              ElevatedButton(
                onPressed: () {
                  Navigator.restorablePushNamed(
                      context, PlaygroundScreen.routeName);
                },
                child: Text('Playground'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.restorablePushNamed(context,
                      AdministrationScreen.mainNavigationItem.routeName);
                },
                child: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      AdministrationScreen.mainNavigationItem.icon,
                      Text('Mehr...'),
                    ],
                  ),
                ),
              ),
              Placeholder(fallbackHeight: 500),
              Placeholder(fallbackHeight: 500),
            ],
          ),
        ),
      ),
    );
  }
}
