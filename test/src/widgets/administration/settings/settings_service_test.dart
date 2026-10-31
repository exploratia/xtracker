import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/wallpaper_style.dart';
import 'package:xtracker/src/util/device_storage/device_storage.dart';
import 'package:xtracker/src/util/device_storage/device_storage_keys.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('data screen wallpapers default to disabled for existing installs', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final controller = SettingsController(SettingsService());
    addTearDown(controller.dispose);
    await controller.loadSettings();
    expect(controller.showWallpaper, isTrue);
    expect(await SettingsService().showWallpaperOnDataScreens(), isFalse);
    expect(controller.showWallpaperOnDataScreens, isFalse);
    expect(controller.showDataScreenWallpaper, isFalse);
  });

  test('data screen visibility persists and respects global wallpaper visibility', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final controller = SettingsController(SettingsService());
    addTearDown(controller.dispose);
    await controller.loadSettings();
    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.updateShowWallpaperOnDataScreens(true);
    await controller.updateShowWallpaperOnDataScreens(true);
    expect(notifications, 1);
    expect(controller.showDataScreenWallpaper, isTrue);
    await controller.updateHideWallpaper(true);
    expect(controller.showDataScreenWallpaper, isFalse);

    final reloaded = SettingsController(SettingsService());
    addTearDown(reloaded.dispose);
    await reloaded.loadSettings();
    expect(reloaded.showWallpaperOnDataScreens, isTrue);
    expect(reloaded.showDataScreenWallpaper, isFalse);
    await reloaded.updateHideWallpaper(false);
    expect(reloaded.showDataScreenWallpaper, isTrue);
    await reloaded.updateShowWallpaperOnDataScreens(false);

    final disabled = SettingsController(SettingsService());
    addTearDown(disabled.dispose);
    await disabled.loadSettings();
    expect(disabled.showWallpaperOnDataScreens, isFalse);
    expect(disabled.showDataScreenWallpaper, isFalse);
  });

  test('failed persistence keeps data screen wallpapers disabled without notifying', () async {
    final controller = SettingsController(_FailingWallpaperSettingsService());
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);
    await expectLater(controller.updateShowWallpaperOnDataScreens(true), throwsStateError);
    expect(controller.showWallpaperOnDataScreens, isFalse);
    expect(notifications, 0);
  });

  test('every wallpaper motif survives a settings service round trip', () async {
    FlutterSecureStorage.setMockInitialValues({});
    for (final style in WallpaperStyle.values) {
      await SettingsService().updateWallpaperStyle(style);
      expect(await SettingsService().wallpaperStyle(), style);
    }
  });

  test('wallpaper defaults preserve existing installs and tolerate unknown values', () async {
    for (final stored in [null, 'unknown', 'hills', '']) {
      FlutterSecureStorage.setMockInitialValues({DeviceStorageKeys.wallpaperStyle: ?stored});
      expect(await SettingsService().wallpaperStyle(), WallpaperStyle.hills);
    }
  });

  test('wallpaper selection survives reloads independently of visibility', () async {
    FlutterSecureStorage.setMockInitialValues({DeviceStorageKeys.layoutHideWallpaper: 'hidden'});
    final controller = SettingsController(SettingsService());
    addTearDown(controller.dispose);
    await controller.loadSettings();
    var notifications = 0;
    controller.addListener(() => notifications++);
    await controller.updateWallpaperStyle(WallpaperStyle.mountainLake);
    await controller.updateWallpaperStyle(WallpaperStyle.mountainLake);
    expect(notifications, 1);
    expect(controller.hideWallpaper, isTrue);
    expect(await DeviceStorage.read(DeviceStorageKeys.wallpaperStyle), 'mountainLake');
    final reloaded = SettingsController(SettingsService());
    addTearDown(reloaded.dispose);
    await reloaded.loadSettings();
    expect(reloaded.wallpaperStyle, WallpaperStyle.mountainLake);
    expect(reloaded.hideWallpaper, isTrue);
  });

  test('failed persistence preserves the previous wallpaper selection', () async {
    final controller = SettingsController(_FailingWallpaperSettingsService());
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);
    await expectLater(controller.updateWallpaperStyle(WallpaperStyle.mountainLake), throwsStateError);
    expect(controller.wallpaperStyle, WallpaperStyle.hills);
    expect(notifications, 0);
  });

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

class _FailingWallpaperSettingsService extends SettingsService {
  @override
  Future<void> updateShowWallpaperOnDataScreens(bool value) async => throw StateError('Storage unavailable');

  @override
  Future<void> updateWallpaperStyle(WallpaperStyle value) async => throw StateError('Storage unavailable');
}
