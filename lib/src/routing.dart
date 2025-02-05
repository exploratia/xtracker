import 'package:flutter/material.dart';

import 'model/navigation/navigation_item.dart';
import 'screens/administration/administration_screen.dart';
import 'screens/administration/info_screen.dart';
import 'screens/administration/log_screen.dart';
import 'screens/administration/log_settings_screen.dart';
import 'screens/administration/logs_screen.dart';
import 'screens/administration/settings_screen.dart';
import 'screens/home_screen.dart';
import 'screens/playground_screen.dart';
import 'widgets/administration/settings/settings_controller.dart';
import 'widgets/playground/hero/hero_view.dart';
import 'widgets/playground/sample_feature/sample_item_details_view.dart';
import 'widgets/playground/sample_feature/sample_item_list_view.dart';

class Routing {
  final SettingsController settingsController;

  final Map<String, Widget> _routeMapping = {};

  void _addMapping(Widget widget, NavigationItem navItem) {
    _routeMapping[navItem.routeName] = widget;
  }

  Routing(this.settingsController) {
    // Build map for all Screens. Because of flutters code optimization we have to call every widget itself.
    // No generic solution possible :(
    _addMapping(const HomeScreen(), HomeScreen.navItem);
    // administration
    _addMapping(const AdministrationScreen(), AdministrationScreen.navItem);
    _addMapping(const LogsScreen(), LogsScreen.navItem);
    _addMapping(const LogScreen(), LogScreen.navItem);
    _addMapping(const LogSettingsScreen(), LogSettingsScreen.navItem);
    _addMapping(const InfoScreen(), InfoScreen.navItem);
    _addMapping(
        SettingsScreen(controller: settingsController), SettingsScreen.navItem);

    _addMapping(const PlaygroundScreen(), PlaygroundScreen.navItem);
  }

  Route<dynamic>? generateRoute(RouteSettings routeSettings) {
    return MaterialPageRoute<void>(
      settings: routeSettings,
      builder: (BuildContext context) {
        String? routeName = routeSettings.name;

        if (routeName != null) {
          var widget = _routeMapping[routeName];
          if (widget != null) return widget;
        }

        switch (routeSettings.name) {
          // playground >>
          case SampleItemDetailsView.routeName:
            return const SampleItemDetailsView();
          case SampleItemListView.routeName:
            return const SampleItemListView();
          case HeroView.routeName:
            return const HeroView();
          // << playground
        }

        // fallback
        return const HomeScreen();
      },
    );
  }
}
