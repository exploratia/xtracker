import 'dart:typed_data';

/// Web previews keep their image in the settings controller for this session.
class WallpaperImageStorage {
  /// No image is restored after reloading the browser.
  Future<Uint8List?> read() async => null;

  /// Persistent storage is only needed on native platforms.
  Future<void> write(Uint8List bytes) async {}
}
