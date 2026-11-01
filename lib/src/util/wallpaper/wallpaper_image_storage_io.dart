import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Stores a private copy independently of the gallery and picker cache.
class WallpaperImageStorage {
  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/wallpaper/image');
  }

  /// Reads the saved image, or null when none has been selected yet.
  Future<Uint8List?> read() async {
    final file = await _file();
    return await file.exists() ? file.readAsBytes() : null;
  }

  /// Replaces the image only after its complete contents have been flushed.
  Future<void> write(Uint8List bytes) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsBytes(bytes, flush: true);
    await temporary.rename(file.path);
  }
}
