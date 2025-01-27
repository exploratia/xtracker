import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screens/administration/log_screen.dart';
import 'screens/administration/log_settings_screen.dart';
import 'screens/administration/logs_screen.dart';
import 'screens/administration/settings_screen.dart';
import 'screens/home_screen.dart';
import 'screens/playground_screen.dart';
import 'widgets/administration/settings/settings_controller.dart';
import 'widgets/playground/sample_feature/sample_item_details_view.dart';
import 'widgets/playground/sample_feature/sample_item_list_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          // localizationsDelegates: const [
          //   AppLocalizations.delegate,
          //   GlobalMaterialLocalizations.delegate,
          //   GlobalWidgetsLocalizations.delegate,
          //   GlobalCupertinoLocalizations.delegate,
          // ],
          // supportedLocales: const [
          //   Locale('en', ''), // English, no country code
          //   Locale('de', ''), // German, no country code
          // ],
          // instead of doing it manually use generic:
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            useMaterial3: false,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueAccent), // TODO theme data
          ),
          darkTheme: ThemeData.dark(useMaterial3: false),
          themeMode: settingsController.themeMode,
          locale: settingsController.locale,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case PlaygroundScreen.routeName:
                    return PlaygroundScreen();
                  // administration >>
                  case SettingsScreen.routeName:
                    return SettingsScreen(controller: settingsController);
                  case LogsScreen.routeName:
                    return const LogsScreen();
                  case LogScreen.routeName:
                    return const LogScreen();
                  case LogSettingsScreen.routeName:
                    return const LogSettingsScreen();
                  // << administration
                  case SampleItemDetailsView.routeName:
                    return const SampleItemDetailsView();
                  case SampleItemListView.routeName:
                    return const SampleItemListView();
                  case HomeScreen.routeName:
                  default:
                    return const HomeScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}
