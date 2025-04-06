import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/locale_keys.g.dart';
import 'model/navigation/navigation.dart';
import 'providers/series_current_value_provider.dart';
import 'providers/series_data_provider.dart';
import 'providers/series_provider.dart';
import 'routing.dart';
import 'util/date_time_utils.dart';
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
            ChangeNotifierProvider(create: (context) => SeriesCurrentValueProvider()),
          ],
          child: MaterialApp(
            // Providing a restorationScopeId allows the Navigator built by the
            // MaterialApp to restore the navigation stack when a user leaves and
            // returns to the app after it has been killed while running in the
            // background.
            restorationScopeId: 'app',

            // locale
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            // locale: settingsController.locale,

            onGenerateTitle: (BuildContext context) {
              // settings changed -> maybe locale? ->
              Intl.defaultLocale = context.locale.languageCode;
              DateTimeUtils.init();
              // when locale is changed text width could be different -> recalc
              Navigation.resetMaxTextWidth();
              return LocaleKeys.appTitle.tr();
            },

            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: ThemeUtils.buildThemeData(context, false),
            darkTheme: ThemeUtils.buildThemeData(context, true),
            themeMode: settingsController.themeMode,

            // Mouse dragging enabled
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: PointerDeviceKind.values.toSet(),
            ),

            debugShowCheckedModeBanner: false,

            // Define a function to handle named routes in order to support
            // Flutter web url navigation and deep linking.
            onGenerateRoute: routing.generateRoute,
          ),
        );
      },
    );
  }
}
