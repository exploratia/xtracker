import 'dart:io';
import 'dart:typed_data';

import 'package:xtracker/src/util/wallpaper/wallpaper_image_service.dart';
import 'package:xtracker/src/util/wallpaper/wallpaper_image_storage.dart';

Uint8List wallpaperImageFixture() => File('assets/images/logos/app_logo.png').readAsBytesSync();

class MemoryWallpaperImageStorage extends WallpaperImageStorage {
  Uint8List? bytes;
  bool failWrites = false;

  @override
  Future<Uint8List?> read() async => bytes;

  @override
  Future<void> write(Uint8List value) async {
    if (failWrites) throw StateError('Storage unavailable');
    bytes = value;
  }
}

class SelectableWallpaperImageService extends WallpaperImageService {
  SelectableWallpaperImageService({required super.storage});

  Uint8List? selection;
  int selections = 0;

  @override
  Future<Uint8List?> pick() async {
    selections++;
    return selection;
  }
}
