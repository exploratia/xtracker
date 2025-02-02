import 'package:flutter/material.dart';

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

  Routing(this.settingsController);

  Route<dynamic>? generateRoute(RouteSettings routeSettings) {
    return MaterialPageRoute<void>(
      settings: routeSettings,
      builder: (BuildContext context) {
        switch (routeSettings.name) {
          case PlaygroundScreen.routeName:
            return const PlaygroundScreen();
          // administration >>
          case AdministrationScreen.routeName:
            return const AdministrationScreen();
          case SettingsScreen.routeName:
            return SettingsScreen(controller: settingsController);
          case LogsScreen.routeName:
            return const LogsScreen();
          case LogScreen.routeName:
            return const LogScreen();
          case LogSettingsScreen.routeName:
            return const LogSettingsScreen();
          case InfoScreen.routeName:
            return const InfoScreen();
          // << administration
          // playground >>
          case SampleItemDetailsView.routeName:
            return const SampleItemDetailsView();
          case SampleItemListView.routeName:
            return const SampleItemListView();
          case HeroView.routeName:
            return const HeroView();
          // << playground
          // home
          case HomeScreen.routeName:
          default:
            return const HomeScreen();
        }
      },
    );
  }
}
