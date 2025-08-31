import 'package:flutter/material.dart';

import '../../../util/device_storage/device_storage.dart';
import '../../../util/device_storage/device_storage_keys.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  static const supportedLocales = [Locale('en', 'US'), Locale('de', 'DE')];

  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async {
    var value = await DeviceStorage.read(DeviceStorageKeys.theme);
    if (value == 'dark') return ThemeMode.dark;
    if (value == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    String? value = theme.name;
    if (value == "system") value = null;
    await DeviceStorage.write(DeviceStorageKeys.theme, value);
  }

  /// Loads the User's preferred Locale
  Future<Locale?> locale() async {
    var value = await DeviceStorage.read(DeviceStorageKeys.language);
    if (value == null) return null;
    // if language code is not enough add country code as well
    var localeIdx = supportedLocales.indexWhere((element) => element.languageCode == value);
    if (localeIdx < 0) return null;

    var locale = supportedLocales[localeIdx];
    return locale;
  }

  /// Persists the user's preferred Locale to local or remote storage.
  Future<void> updateLocale(Locale? locale) async {
    var value = locale == null ? null : (locale.languageCode);
    await DeviceStorage.write(DeviceStorageKeys.language, value);
  }

  /// Loads the User's preferred nav label settings
  Future<bool> hideNavigationLabels() async {
    return await DeviceStorage.readBool(DeviceStorageKeys.layoutHideNavLabels);
  }

  /// Persists the user's preferred setting
  Future<void> updateHideNavigationLabels(bool value) async {
    await DeviceStorage.writeBool(DeviceStorageKeys.layoutHideNavLabels, value);
  }

  /// Loads the initial app start and set if not yet exists
  Future<DateTime> initialAppStart() async {
    var strTimestamp = await DeviceStorage.read(DeviceStorageKeys.initialAppStart);
    DateTime? timestamp;
    if (strTimestamp != null) {
      var split = strTimestamp.split("-");
      if (split.length == 3) {
        int? year = int.tryParse(split[0], radix: 10);
        int? month = int.tryParse(split[1], radix: 10);
        int? day = int.tryParse(split[2], radix: 10);
        if (year != null && month != null && day != null) {
          timestamp = DateTime(year, month = month, day = day);
        }
      }
    }
    if (timestamp == null) {
      timestamp = DateTime.now();
      await DeviceStorage.write(DeviceStorageKeys.initialAppStart, '${timestamp.year}-${timestamp.month}-${timestamp.day}');
    }
    return timestamp;
  }
}
