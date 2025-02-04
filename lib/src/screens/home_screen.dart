import 'package:flutter/material.dart';

import '../model/navigation/main_navigation.dart';
import '../model/navigation/main_navigation_item.dart';
import '../util/globals.dart';
import '../util/navigation/hide_bottom_navigation_bar.dart';
import '../widgets/layout/gradient_app_bar.dart';
import '../widgets/layout/single_child_scroll_view_with_scrollbar.dart';
import '../widgets/responsive/screen_builder.dart';
import './playground_screen.dart';
import 'administration/administration_screen.dart';

class HomeScreen extends StatelessWidget {
  static MainNavigationItem mainNavigationItem = MainNavigationItem(
      icon: const Icon(Icons.home_outlined),
      routeName: '/',
      titleBuilder: (t) => t.homeTitle,
      screenBuilder: () => const HomeScreen());

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder.withStandardNavBuilders(
      isHome: true,
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
      ),
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
                MainNavigation.setRoute(
                    AdministrationScreen.mainNavigationItem.routeName, context);
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
    );
  }
}
