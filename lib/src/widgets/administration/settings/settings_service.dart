import 'package:flutter/material.dart';

import '../../../util/device_storage/device_storage.dart';
import '../../../util/device_storage/device_storage_keys.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async {
    var value = await DeviceStorage.read(DeviceStorageKeys.keyAppTheme);
    if (value == 'dark') return ThemeMode.dark;
    if (value == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    var value = theme.name;
    await DeviceStorage.write(DeviceStorageKeys.keyAppTheme, value);
  }

  /// Loads the User's preferred Locale
  Future<Locale?> locale() async {
    var value = await DeviceStorage.read(DeviceStorageKeys.keyAppLocale);
    return (value == null ? null : Locale(value));
  }

  /// Persists the user's preferred Locale to local or remote storage.
  Future<void> updateLocale(Locale? locale) async {
    var value = locale?.languageCode;
    await DeviceStorage.write(DeviceStorageKeys.keyAppLocale, value);
  }
}
