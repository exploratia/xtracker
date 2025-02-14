import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'model/navigation/navigation.dart';
import 'providers/series_data_provider.dart';
import 'providers/series_provider.dart';
import 'routing.dart';
import 'util/theme_utils.dart';
import 'widgets/administration/settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    final routing = Routing(settingsController);

    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => SeriesProvider()),
            ChangeNotifierProvider(create: (context) => SeriesDataProvider()),
          ],
          child: MaterialApp(
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
            onGenerateTitle: (BuildContext context) {
              // settings changed -> maybe locale? ->
              Navigation.resetMaxTextWidth();
              return AppLocalizations.of(context)!.appTitle;
            },

            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: ThemeUtils.buildThemeData(context, false),
            darkTheme: ThemeUtils.buildThemeData(context, true),
            themeMode: settingsController.themeMode,
            locale: settingsController.locale,

            // Define a function to handle named routes in order to support
            // Flutter web url navigation and deep linking.
            onGenerateRoute: routing.generateRoute,
          ),
        );
      },
    );
  }
}
