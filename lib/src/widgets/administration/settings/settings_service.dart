import 'package:material_ui/material_ui.dart';

import '../../../util/app_info.dart';
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

  Future<bool> hideWallpaper() async {
    return await DeviceStorage.readBool(DeviceStorageKeys.layoutHideWallpaper);
  }

  Future<void> updateHideWallpaper(bool value) async {
    await DeviceStorage.writeBool(DeviceStorageKeys.layoutHideWallpaper, value);
  }

  Future<bool> hideExploratiaQuickActionUrl() async {
    return await DeviceStorage.readBool(DeviceStorageKeys.quickActionsHideExploratiaUrl);
  }

  Future<void> updateHideExploratiaQuickActionUrl(bool value) async {
    await DeviceStorage.writeBool(DeviceStorageKeys.quickActionsHideExploratiaUrl, value);
  }

  /// Loads whether automatic Dropbox backups are enabled.
  Future<bool> autoBackupEnabled() async {
    return DeviceStorage.readBool(DeviceStorageKeys.autoBackupEnabled);
  }

  /// Persists whether automatic Dropbox backups are enabled.
  Future<void> updateAutoBackupEnabled(bool value) async {
    await DeviceStorage.writeBool(DeviceStorageKeys.autoBackupEnabled, value);
  }

  /// Removes all settings that belong to automatic Dropbox backups.
  Future<void> resetAutoBackupSettings() async {
    await Future.wait([
      DeviceStorage.delete(DeviceStorageKeys.autoBackupEnabled),
      DeviceStorage.delete(DeviceStorageKeys.autoBackupIntervalDays),
      DeviceStorage.delete(DeviceStorageKeys.autoBackupNextDate),
      DeviceStorage.delete(DeviceStorageKeys.autoBackupDate),
    ]);
  }

  /// Loads the configured automatic backup interval in days.
  Future<int> autoBackupIntervalDays() async {
    final storedValue = await DeviceStorage.read(DeviceStorageKeys.autoBackupIntervalDays);
    return int.tryParse(storedValue ?? '') ?? 3;
  }

  /// Persists the automatic backup interval in days.
  Future<void> updateAutoBackupIntervalDays(int value) async {
    await DeviceStorage.write(DeviceStorageKeys.autoBackupIntervalDays, value.toString());
  }

  /// Loads the next automatic backup date without a time component.
  Future<DateTime?> autoBackupNextDate() async {
    final storedValue = await DeviceStorage.read(DeviceStorageKeys.autoBackupNextDate);
    if (storedValue == null) return null;

    // Accept the former ISO-8601 value so existing installations migrate
    // transparently to day-based scheduling.
    final parsedValue = _parseDate(storedValue) ?? DateTime.tryParse(storedValue);
    return parsedValue == null ? null : DateTime(parsedValue.year, parsedValue.month, parsedValue.day);
  }

  /// Persists the next automatic backup as a calendar date.
  Future<void> updateAutoBackupNextDate(DateTime value) async {
    await DeviceStorage.write(DeviceStorageKeys.autoBackupNextDate, _toDateStr(value));
  }

  /// Loads the date of the latest successful automatic backup.
  Future<DateTime?> autoBackupDate() async {
    return _parseDate(await DeviceStorage.read(DeviceStorageKeys.autoBackupDate));
  }

  /// Persists the date of the latest successful automatic backup.
  Future<void> updateAutoBackupDate(DateTime value) async {
    await DeviceStorage.write(DeviceStorageKeys.autoBackupDate, _toDateStr(value));
  }

  /// Loads the initial app start and set if not yet exists
  Future<DateTime> initialAppStart() async {
    var strTimestamp = await DeviceStorage.read(DeviceStorageKeys.initialAppStart);
    DateTime? timestamp = _parseDate(strTimestamp);
    if (timestamp == null) {
      timestamp = DateTime.now();
      await DeviceStorage.write(DeviceStorageKeys.initialAppStart, _toDateStr(timestamp));
    }
    return timestamp;
  }

  /// Persists the current app version and returns the previously stored version.
  /// If not set so far, 1.4.0 is returned as it is the version after which the changelog was invented.
  Future<String> appVersion() async {
    var previousVersion = await DeviceStorage.read(DeviceStorageKeys.appVersion) ?? "1.4.0";
    await DeviceStorage.write(DeviceStorageKeys.appVersion, AppInfo.version);
    return previousVersion;
  }

  /// Loads last series export date (if any)
  Future<DateTime?> seriesExportDate() async {
    var strTimestamp = await DeviceStorage.read(DeviceStorageKeys.seriesExportDate);
    DateTime? timestamp = _parseDate(strTimestamp);
    return timestamp;
  }

  /// Persists series export date
  Future<DateTime> updateSeriesExportDate() async {
    var dateTime = DateTime.now();
    await DeviceStorage.write(DeviceStorageKeys.seriesExportDate, _toDateStr(dateTime));
    return dateTime;
  }

  Future<bool> seriesExportDisableReminder() async {
    return await DeviceStorage.readBool(DeviceStorageKeys.seriesExportDisableReminder);
  }

  Future<void> updateSeriesExportDisableReminder(bool value) async {
    await DeviceStorage.writeBool(DeviceStorageKeys.seriesExportDisableReminder, value);
  }

  /// Loads series export reminder date (if any)
  Future<DateTime?> seriesExportReminderDate() async {
    var strTimestamp = await DeviceStorage.read(DeviceStorageKeys.seriesExportReminderDate);
    DateTime? timestamp = _parseDate(strTimestamp);
    return timestamp;
  }

  /// Persists series export reminder date
  Future<void> updateSeriesExportReminderDate(DateTime dateTime) async {
    await DeviceStorage.write(DeviceStorageKeys.seriesExportReminderDate, _toDateStr(dateTime));
  }

  /// Loads app support reminder date (if any)
  Future<DateTime?> appSupportReminderDate() async {
    var strTimestamp = await DeviceStorage.read(DeviceStorageKeys.appSupportReminderDate);
    DateTime? timestamp = _parseDate(strTimestamp);
    return timestamp;
  }

  /// Persists app support reminder date
  Future<void> updateAppSupportReminderDate(DateTime dateTime) async {
    await DeviceStorage.write(DeviceStorageKeys.appSupportReminderDate, _toDateStr(dateTime));
  }

  static String _toDateStr(DateTime timestamp) => '${timestamp.year}-${timestamp.month}-${timestamp.day}';

  static DateTime? _parseDate(String? strTimestamp) {
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
    return timestamp;
  }
}
