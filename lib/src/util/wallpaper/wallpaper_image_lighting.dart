import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import '../../widgets/controls/live_wallpaper/wallpaper_day_cycle.dart';

/// Image-aware day/night grading that preserves the shadows of dark photos.
@immutable
class WallpaperImageLighting {
  /// Creates lighting from the image center's average perceived brightness.
  const WallpaperImageLighting({required this.luminance});

  /// Average perceived brightness of the central area, from black (0) to white (1).
  final double luminance;

  /// Samples the center of a small thumbnail once, independently of display size.
  static Future<WallpaperImageLighting> fromBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 32, targetHeight: 32);
    try {
      final frame = await codec.getNextFrame();
      try {
        final pixels = await frame.image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
        if (pixels == null) throw StateError('Wallpaper pixels are unavailable.');
        return WallpaperImageLighting.fromPixels(
          pixels.buffer.asUint8List(pixels.offsetInBytes, pixels.lengthInBytes),
          width: frame.image.width,
          height: frame.image.height,
        );
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  /// Averages the middle 50% of each dimension, weighting RGBA pixels by alpha.
  ///
  /// Outer quarters are commonly cropped by the centered wallpaper layout.
  /// Ignoring them keeps bright borders from obscuring a dark center and vice versa.
  factory WallpaperImageLighting.fromPixels(Uint8List pixels, {required int width, required int height}) {
    if (width < 0 || height < 0 || pixels.length != width * height * 4) {
      throw ArgumentError('RGBA pixel data must match the image dimensions.');
    }
    final left = width ~/ 4;
    final top = height ~/ 4;
    var total = 0.0;
    var weight = 0.0;
    for (var y = top; y < height - top; y++) {
      for (var x = left; x < width - left; x++) {
        final i = (y * width + x) * 4;
        final alpha = pixels[i + 3] / 255;
        total += (0.2126 * pixels[i] + 0.7152 * pixels[i + 1] + 0.0722 * pixels[i + 2]) / 255 * alpha;
        weight += alpha;
      }
    }
    return WallpaperImageLighting(luminance: weight == 0 ? 0 : total / weight);
  }

  /// Dims bright pictures by up to 45%, leaving dark pictures at their original brightness.
  double brightnessAt(double percentOfDay) {
    // Dark images need no further dimming. Smoothly increase it for brighter ones.
    final strength = ((luminance - 0.12) / 0.43).clamp(0.0, 1.0);
    final dimming = strength * strength * (3 - 2 * strength);
    return 1 - 0.45 * dimming * WallpaperDayCycle(percentOfDay).starOpacity;
  }

  /// Reduces saturation by up to 30% during the night and twilight.
  double saturationAt(double percentOfDay) => 1 - 0.30 * WallpaperDayCycle(percentOfDay).starOpacity;

  /// Identity by day; at night desaturates by 30% and dims by at most 45%.
  ui.ColorFilter filterAt(double percentOfDay) {
    final brightness = brightnessAt(percentOfDay);
    final saturation = saturationAt(percentOfDay);
    final red = 0.2126 * (1 - saturation) * brightness;
    final green = 0.7152 * (1 - saturation) * brightness;
    final blue = 0.0722 * (1 - saturation) * brightness;
    final diagonal = saturation * brightness;
    return ui.ColorFilter.matrix([
      red + diagonal,
      green,
      blue,
      0,
      0,
      red,
      green + diagonal,
      blue,
      0,
      0,
      red,
      green,
      blue + diagonal,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }
}
