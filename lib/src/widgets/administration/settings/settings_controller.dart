import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../util/navigation/hide_navigation_labels.dart';
import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;

  Locale? _locale;

  Locale? get locale => _locale;

  bool _hideNavigationLabels = true;

  bool get hideNavigationLabels => _hideNavigationLabels;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _locale = await _settingsService.locale();
    _hideNavigationLabels = await _settingsService.hideNavigationLabels();
    HideNavigationLabels.setVisible(!_hideNavigationLabels);
    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  /// Update and persist the Locale based on the user's selection.
  Future<void> updateLocale(Locale? newLocale, BuildContext context) async {
    // if (val == null) return; // null is ok -> system language

    // Do not perform any work if new and old ThemeMode are identical
    if (newLocale == _locale) return;

    // Otherwise, store the new ThemeMode in memory
    _locale = newLocale;

    // Important! Inform listeners a change has occurred.
    await updateContextLocale(context);
    notifyListeners(); // necessary for UI rebuild

    // Persist the changes to a local database or the internet using the SettingService.
    await _settingsService.updateLocale(newLocale);
  }

  Future<void> updateContextLocale(BuildContext context) async {
    Locale locale = context.deviceLocale;
    if (_locale != null) {
      locale = _locale!;
    }
    if (!context.supportedLocales.contains(locale)) {
      locale = context.deviceLocale;
      if (!context.supportedLocales.contains(locale)) {
        locale = SettingsService.supportedLocales[0];
      }
    }
    await context.setLocale(locale);
  }

  /// Update and persist the hide nav labels based on the user's selection.
  Future<void> updateHideNavigationLabels(bool value) async {
    // Do not perform any work if new and old are identical
    if (value == _hideNavigationLabels) return;

    // Otherwise, store in memory
    _hideNavigationLabels = value;

    // Important! Inform listeners a change has occurred.
    // notifyListeners();
    HideNavigationLabels.setVisible(!_hideNavigationLabels);

    // Persist the changes to a local database or the internet using the SettingService.
    await _settingsService.updateHideNavigationLabels(value);
  }
}
