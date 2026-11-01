import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/wallpaper_style.dart';
import 'package:xtracker/src/util/device_storage/device_storage_keys.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';

import '../../../../support/wallpaper_image_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MemoryWallpaperImageStorage storage;
  late SelectableWallpaperImageService images;
  late SettingsController controller;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    storage = MemoryWallpaperImageStorage();
    images = SelectableWallpaperImageService(storage: storage);
    controller = SettingsController(SettingsService(wallpaperImageService: images));
    await controller.loadSettings();
  });

  tearDown(() => controller.dispose());

  test('image and motif survive restart, hiding and switching to live motifs', () async {
    images.selection = wallpaperImageFixture();
    await controller.selectWallpaperImage();
    expect(controller.wallpaperStyle, WallpaperStyle.customImage);
    expect(controller.wallpaperImage, images.selection);
    final lighting = controller.wallpaperImageLighting;
    expect(lighting.luminance, inExclusiveRange(0.0, 1.0));
    await controller.updateHideWallpaper(true);
    expect(controller.wallpaperImageLighting, same(lighting));
    await controller.updateWallpaperStyle(WallpaperStyle.riverValley);
    expect(controller.wallpaperImageLighting, same(lighting));
    await controller.updateWallpaperStyle(WallpaperStyle.customImage);
    expect(controller.wallpaperImageLighting, same(lighting));

    final reloaded = SettingsController(SettingsService(wallpaperImageService: images));
    addTearDown(reloaded.dispose);
    await reloaded.loadSettings();
    expect(reloaded.wallpaperStyle, WallpaperStyle.customImage);
    expect(reloaded.wallpaperImage, images.selection);
    expect(reloaded.wallpaperImageLighting.luminance, closeTo(lighting.luminance, 0.00001));
    expect(reloaded.hideWallpaper, isTrue);
    await reloaded.updateWallpaperStyle(WallpaperStyle.riverValley);

    final liveReloaded = SettingsController(SettingsService(wallpaperImageService: images));
    addTearDown(liveReloaded.dispose);
    await liveReloaded.loadSettings();
    expect(liveReloaded.wallpaperStyle, WallpaperStyle.riverValley);
    expect(liveReloaded.wallpaperImage, images.selection);
    await liveReloaded.updateWallpaperStyle(WallpaperStyle.customImage);
    expect(images.selections, 1);
  });

  test('picker cancellation preserves the current image without notification', () async {
    images.selection = wallpaperImageFixture();
    await controller.selectWallpaperImage();
    final previous = controller.wallpaperImage;
    final lighting = controller.wallpaperImageLighting;
    var notifications = 0;
    controller.addListener(() => notifications++);
    images.selection = null;
    await controller.selectWallpaperImage();
    expect(controller.wallpaperImage, same(previous));
    expect(controller.wallpaperImageLighting, same(lighting));
    expect(controller.wallpaperStyle, WallpaperStyle.customImage);
    expect(notifications, 0);
  });

  test('write failure and invalid selection preserve the live motif', () async {
    var notifications = 0;
    controller.addListener(() => notifications++);
    images.selection = Uint8List.fromList([1, 2, 3]);
    await expectLater(controller.selectWallpaperImage(), throwsA(anything));
    images.selection = wallpaperImageFixture();
    storage.failWrites = true;
    await expectLater(controller.selectWallpaperImage(), throwsStateError);
    expect(controller.wallpaperStyle, WallpaperStyle.hills);
    expect(controller.wallpaperImage, isNull);
    expect(notifications, 0);
  });

  test('custom motif requires an image', () async {
    await expectLater(controller.updateWallpaperStyle(WallpaperStyle.customImage), throwsStateError);
    expect(controller.wallpaperStyle, WallpaperStyle.hills);
  });

  for (final corrupt in [false, true]) {
    test('a ${corrupt ? 'corrupt' : 'missing'} image falls back without preventing startup', () async {
      FlutterSecureStorage.setMockInitialValues({
        DeviceStorageKeys.wallpaperStyle: WallpaperStyle.customImage.name,
        DeviceStorageKeys.wallpaperImageSelected: 'selected',
      });
      if (corrupt) storage.bytes = Uint8List.fromList([1, 2, 3]);
      await controller.loadSettings();
      expect(controller.wallpaperStyle, WallpaperStyle.hills);
      expect(controller.wallpaperImage, isNull);
      expect(controller.wallpaperImageLoadFailed, isTrue);
      images.selection = wallpaperImageFixture();
      await controller.selectWallpaperImage();
      expect(controller.wallpaperImageLoadFailed, isFalse);
    });
  }
}
