import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';

import 'wallpaper_image_storage.dart';

/// Selects, validates and stores a static wallpaper without gallery permissions.
class WallpaperImageService {
  WallpaperImageService({WallpaperImageStorage? storage}) : _storage = storage ?? WallpaperImageStorage();

  final WallpaperImageStorage _storage;

  /// Opens the platform image picker. Cancellation leaves the current image intact.
  Future<Uint8List?> pick() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    return file?.readAsBytes();
  }

  /// Restores a previously selected image and checks that Flutter can decode it.
  Future<Uint8List?> load() async {
    final bytes = await _storage.read();
    if (bytes != null) await _validate(bytes);
    return bytes?.asUnmodifiableView();
  }

  /// Validates before writing so an invalid selection cannot replace a wallpaper.
  Future<Uint8List> save(Uint8List bytes) async {
    final image = Uint8List.fromList(bytes).asUnmodifiableView();
    await _validate(image);
    await _storage.write(image);
    return image;
  }

  Future<void> _validate(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 1, targetHeight: 1);
    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }
  }
}
