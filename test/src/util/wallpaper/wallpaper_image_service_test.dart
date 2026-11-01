import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/wallpaper/wallpaper_image_service.dart';
import 'package:xtracker/src/util/wallpaper/wallpaper_image_storage_web.dart' as web;

import '../../../support/wallpaper_image_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('native image copy survives service recreation and replacement', () async {
    final directory = await Directory.systemTemp.createTemp('xtracker-wallpaper-test-');
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getApplicationSupportDirectory');
      return directory.path;
    });
    addTearDown(() async {
      messenger.setMockMethodCallHandler(channel, null);
      await directory.delete(recursive: true);
    });

    final service = WallpaperImageService();
    expect(await service.load(), isNull);
    final original = wallpaperImageFixture();
    await service.save(original);
    final lighting = service.lighting;
    expect(lighting.luminance, inExclusiveRange(0.0, 1.0));
    expect(service.lighting, same(lighting));
    expect(await WallpaperImageService().load(), original);
    // A real second image exercises replacing an existing native file.
    final replacement = await File('assets/images/logos/app_logo_white.png').readAsBytes();
    await service.save(replacement);
    expect(await WallpaperImageService().load(), replacement);
    expect(await File('${directory.path}/wallpaper/image.tmp').exists(), isFalse);
  });

  test('invalid or empty selections preserve the previous stored image', () async {
    final storage = MemoryWallpaperImageStorage();
    final service = WallpaperImageService(storage: storage);
    final original = await service.save(wallpaperImageFixture());
    for (final invalid in [
      Uint8List(0),
      Uint8List.fromList([1, 2, 3]),
    ]) {
      final lighting = service.lighting;
      await expectLater(service.save(invalid), throwsA(anything));
      expect(service.lighting, same(lighting));
      expect(await service.load(), original);
    }
    expect(() => original[0] = 0, throwsUnsupportedError);
  });

  test('failed storage and corrupt persisted images report errors', () async {
    final storage = MemoryWallpaperImageStorage()..failWrites = true;
    final service = WallpaperImageService(storage: storage);
    await expectLater(service.save(wallpaperImageFixture()), throwsStateError);
    expect(storage.bytes, isNull);
    storage.bytes = Uint8List.fromList([1, 2, 3]);
    await expectLater(service.load(), throwsA(anything));
  });

  test('failed replacement preserves the sampled lighting of the saved image', () async {
    final storage = MemoryWallpaperImageStorage();
    final service = WallpaperImageService(storage: storage);
    await service.save(wallpaperImageFixture());
    final lighting = service.lighting;
    storage.failWrites = true;
    final replacement = await File('assets/images/logos/app_logo_white.png').readAsBytes();
    await expectLater(service.save(replacement), throwsStateError);
    expect(service.lighting, same(lighting));
  });

  test('web storage intentionally restores no image', () async {
    final storage = web.WallpaperImageStorage();
    await storage.write(wallpaperImageFixture());
    expect(await storage.read(), isNull);
  });
}
