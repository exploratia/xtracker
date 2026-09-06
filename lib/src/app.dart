import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../generated/locale_keys.g.dart';
import 'model/navigation/navigation.dart';
import 'providers/series_current_value_provider.dart';
import 'providers/series_data_provider.dart';
import 'providers/series_provider.dart';
import 'routing.dart';
import 'screens/home_screen.dart';
import 'util/app_series_notifications.dart';
import 'util/date_time_utils.dart';
import 'util/pending_app_actions.dart';
import 'util/theme_utils.dart';
import 'widgets/administration/settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  int _lastHandledPendingExternalSeriesActionVersion = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PendingAppActions.externalSeriesActionListenable().addListener(_routeToHomeIfExternalActionPending);
    WidgetsBinding.instance.addPostFrameCallback((_) => _synchronizeNotificationsAndRouteIfPending());
  }

  @override
  void dispose() {
    PendingAppActions.externalSeriesActionListenable().removeListener(_routeToHomeIfExternalActionPending);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _synchronizeNotificationsAndRouteIfPending();
        _refreshDueSeriesNotifications();
      });
    }
  }

  void _refreshDueSeriesNotifications() {
    var context = _navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    context.read<SeriesProvider>().refreshDueNotifications();
  }

  void _routeToHomeIfExternalActionPending() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _synchronizeNotificationsAndRouteIfPending());
  }

  Future<void> _synchronizeNotificationsAndRouteIfPending() async {
    await AppSeriesNotifications.synchronizeActiveSeriesNotificationActions();
    _routeToHomeIfExternalSeriesActionPending();
  }

  void _routeToHomeIfExternalSeriesActionPending() {
    var pendingExternalSeriesActionVersion = PendingAppActions.pendingExternalSeriesActionVersion();
    if (!PendingAppActions.hasPendingExternalSeriesAction || _lastHandledPendingExternalSeriesActionVersion == pendingExternalSeriesActionVersion) {
      return;
    }

    var context = _navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    _lastHandledPendingExternalSeriesActionVersion = pendingExternalSeriesActionVersion;
    Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.navItem.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final routing = Routing(widget.settingsController);

    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => SeriesProvider()),
            ChangeNotifierProvider(create: (context) => SeriesDataProvider()),
            ChangeNotifierProvider(create: (context) => SeriesCurrentValueProvider()),
          ],
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            // Providing a restorationScopeId allows the Navigator built by the
            // MaterialApp to restore the navigation stack when a user leaves and
            // returns to the app after it has been killed while running in the
            // background.
            restorationScopeId: 'app',

            // locale
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            // locale: settingsController.locale,
            locale: context.locale,

            onGenerateTitle: (BuildContext context) {
              // settings changed -> maybe locale? ->
              Intl.defaultLocale = context.locale.languageCode;
              DateTimeUtils.init();
              // when locale is changed text width could be different -> recalc
              Navigation.resetMaxTextWidth();
              return LocaleKeys.appTitle.tr();
            },

            // Set the (transparent app logo) icon background color in the android app switcher (worked in emulator - not on real phone :/ )
            // https://stackoverflow.com/questions/75703449/changing-a-flutter-apps-icon-background-color-in-the-android-app-switcher-not/76386962#76386962
            color: const Color(0xff06041f),
            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: ThemeUtils.buildThemeData(context, false),
            darkTheme: ThemeUtils.buildThemeData(context, true),
            themeMode: widget.settingsController.themeMode,

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
