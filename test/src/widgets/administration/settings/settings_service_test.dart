import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/device_storage/device_storage.dart';
import 'package:xtracker/src/util/device_storage/device_storage_keys.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resetAutoBackupSettings removes every automatic backup value', () async {
    FlutterSecureStorage.setMockInitialValues({
      DeviceStorageKeys.autoBackupEnabled: 'enabled',
      DeviceStorageKeys.autoBackupIntervalDays: '14',
      DeviceStorageKeys.autoBackupNextDate: '2026-8-15',
      DeviceStorageKeys.autoBackupDate: '2026-8-1',
      DeviceStorageKeys.theme: 'dark',
    });

    await SettingsService().resetAutoBackupSettings();

    final storedValues = await DeviceStorage.readAll();
    expect(storedValues, {DeviceStorageKeys.theme: 'dark'});
  });

  test('disabling automatic backup restores its in-memory defaults', () async {
    FlutterSecureStorage.setMockInitialValues({
      DeviceStorageKeys.autoBackupEnabled: 'enabled',
      DeviceStorageKeys.autoBackupIntervalDays: '14',
      DeviceStorageKeys.autoBackupNextDate: '2026-8-15',
      DeviceStorageKeys.autoBackupDate: '2026-8-1',
    });
    final controller = SettingsController(SettingsService());
    await controller.loadSettings();

    await controller.updateAutoBackupEnabled(false);

    expect(controller.autoBackupEnabled, isFalse);
    expect(controller.autoBackupIntervalDays, SettingsController.defaultAutoBackupIntervalDays);
    expect(controller.autoBackupNextDate, isNull);
    expect(controller.autoBackupDate, isNull);
    final storedValues = await DeviceStorage.readAll();
    expect(storedValues.keys.where((key) => key.startsWith('autoBackup')), isEmpty);
  });

  test('failed backup retry is scheduled for tomorrow regardless of the interval', () async {
    FlutterSecureStorage.setMockInitialValues({
      DeviceStorageKeys.autoBackupEnabled: 'enabled',
      DeviceStorageKeys.autoBackupIntervalDays: '90',
    });
    final controller = SettingsController(SettingsService());
    await controller.loadSettings();

    await controller.scheduleAutoBackupRetry(DateTime(2026, 8, 6, 23, 59));

    expect(controller.autoBackupNextDate, DateTime(2026, 8, 7));
    expect(await DeviceStorage.read(DeviceStorageKeys.autoBackupNextDate), '2026-8-7');
  });
}
