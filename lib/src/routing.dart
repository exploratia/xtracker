import 'package:flutter/material.dart';

import 'screens/administration/administration_screen.dart';
import 'screens/administration/info_screen.dart';
import 'screens/administration/log_screen.dart';
import 'screens/administration/log_settings_screen.dart';
import 'screens/administration/logs_screen.dart';
import 'screens/administration/settings_screen.dart';
import 'screens/home_screen.dart';
import 'screens/playground_screen.dart';
import 'screens/series/series_data_screen.dart';
import 'util/logging/flutter_simple_logging.dart';
import 'widgets/administration/settings/settings_controller.dart';
import 'widgets/playground/hero/hero_view.dart';
import 'widgets/playground/sample_feature/sample_item_details_view.dart';
import 'widgets/playground/sample_feature/sample_item_list_view.dart';

class Routing {
  final SettingsController settingsController;

  Routing(this.settingsController) {
    // this order (order of instantiation of MainNavigationItem) is used in Nav
    [
      HomeScreen.navItem,
      AdministrationScreen.navItem,
      PlaygroundScreen.navItem,
    ];
  }

  Route<dynamic>? generateRoute(RouteSettings routeSettings) {
    return MaterialPageRoute<void>(
      settings: routeSettings,
      builder: (BuildContext context) {
        String? routeName = routeSettings.name;
        Map<String, dynamic> args = {};

        if (routeName != null) {
          // Handle parameters
          try {
            var uri = Uri.parse('https://domain.com$routeName');
            // routeName = uri.path;
            args = uri.queryParameters;
          } catch (err) {
            SimpleLogging.w('Failed to parse route uri!', error: err);
          }
        }

        if (routeSettings.arguments is Map<String, dynamic>) {
          args = routeSettings.arguments as Map<String, dynamic>;
        }

        // playground >>
        if (routeName == PlaygroundScreen.navItem.routeName) return const PlaygroundScreen();
        if (routeName == SampleItemDetailsView.routeName) return const SampleItemDetailsView();
        if (routeName == SampleItemListView.routeName) return const SampleItemListView();
        if (routeName == HeroView.routeName) return const HeroView();
        // << playground
        // administration >>
        if (routeName == AdministrationScreen.navItem.routeName) return const AdministrationScreen();
        if (routeName == LogsScreen.navItem.routeName) return const LogsScreen();
        if (routeName == LogScreen.navItem.routeName) return const LogScreen();
        if (routeName == LogSettingsScreen.navItem.routeName) return const LogSettingsScreen();
        if (routeName == InfoScreen.navItem.routeName) return const InfoScreen();
        if (routeName == SettingsScreen.navItem.routeName) return SettingsScreen(controller: settingsController);
        // << administration
        // series >>
        if (routeName == SeriesDataScreen.navItem.routeName) return SeriesDataScreen(args: args);
        // << series

        // fallback
        return const HomeScreen();
      },
    );
  }
}
