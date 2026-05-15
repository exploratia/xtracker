import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'device_storage_keys.dart';

class DeviceStorage {
  static const String _symbolChecked = '✓';

  static const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  /// Read value
  static Future<String?> read(String key) async {
    return storage.read(key: key);
  }

  /// Read bool value
  static Future<bool> readBool(String key) async {
    var data = await storage.read(key: key);
    return data == null ? false : true;
  }

  /// Read all values
  static Future<Map<String, String>> readAll() async {
    return storage.readAll();
  }

  /// Delete value
  static Future<void> delete(String key) async {
    return storage.delete(key: key);
  }

  /// Delete all
  static Future<void> deleteAll() async {
    final appVersion = await read(DeviceStorageKeys.appVersion);
    await storage.deleteAll();
    await write(DeviceStorageKeys.appVersion, appVersion);
  }

  /// Write value
  static Future<void> write(String key, String? value) async {
    return storage.write(key: key, value: value);
  }

  /// Write bool value (stores a value if true - otherwise set to null)
  static Future<void> writeBool(String key, bool value) async {
    return storage.write(key: key, value: value ? _symbolChecked : null);
  }
}
