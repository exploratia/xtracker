import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/wallpaper/wallpaper_image_lighting.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('daylight preserves the image at every brightness', () {
    for (final luminance in [0.0, 0.1, 0.3, 0.6, 1.0]) {
      final lighting = WallpaperImageLighting(luminance: luminance);
      for (final hour in [7, 12, 18, 19]) {
        expect(lighting.brightnessAt(hour / 24), 1);
        expect(lighting.saturationAt(hour / 24), 1);
        expect(
          lighting.filterAt(hour / 24),
          const ui.ColorFilter.matrix([
            1,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
        );
      }
    }
  });

  test('night dims bright photos but protects already dark photos', () {
    const dark = WallpaperImageLighting(luminance: 0.08);
    const medium = WallpaperImageLighting(luminance: 0.3);
    const bright = WallpaperImageLighting(luminance: 0.8);
    expect(dark.brightnessAt(0), 1);
    expect(medium.brightnessAt(0), inExclusiveRange(0.55, 1));
    expect(bright.brightnessAt(0), 0.55);
    for (final lighting in [dark, medium, bright]) {
      expect(lighting.saturationAt(0), 0.7);
      expect(lighting.brightnessAt(1), lighting.brightnessAt(0));
      expect(lighting.filterAt(1), lighting.filterAt(0));
    }
  });

  test('rendered filter preserves dark neutral pixels and softens bright colors', () async {
    const dark = WallpaperImageLighting(luminance: 0.08);
    final shadow = await _filteredPixel(dark.filterAt(0), const ui.Color(0xff101010));
    expect(shadow, [16, 16, 16, 255]);
    const bright = WallpaperImageLighting(luminance: 0.8);
    final night = await _filteredPixel(bright.filterAt(0), const ui.Color(0xffc86432));
    expect(night[0], closeTo(96, 1));
    expect(night[1], closeTo(58, 1));
    expect(night[2], closeTo(39, 1));
    expect(night[3], 255);
    final day = await _filteredPixel(bright.filterAt(0.5), const ui.Color(0xffc86432));
    expect(day, [200, 100, 50, 255]);
    final transparent = await _filteredPixel(bright.filterAt(0), const ui.Color(0x00000000));
    expect(transparent, [0, 0, 0, 0]);
  });

  test('dawn and dusk fade gradually and stay continuous at midnight', () {
    const lighting = WallpaperImageLighting(luminance: 0.8);
    expect(lighting.brightnessAt(6 / 24), closeTo(0.775, 0.00001));
    expect(lighting.brightnessAt(20 / 24), closeTo(0.775, 0.00001));
    expect(lighting.saturationAt(6 / 24), closeTo(0.85, 0.00001));
    for (final hour in [5, 7, 19, 21, 24]) {
      final before = lighting.brightnessAt((hour - 0.001) / 24);
      final after = lighting.brightnessAt((hour + 0.001) / 24);
      expect(before, closeTo(after, 0.001));
    }
    var previous = 1.0;
    for (var hour = 19.0; hour <= 21; hour += 0.1) {
      final brightness = lighting.brightnessAt(hour / 24);
      expect(brightness, lessThanOrEqualTo(previous));
      previous = brightness;
    }
  });

  test('sampling uses perceived brightness and ignores fully transparent pixels', () {
    final red = WallpaperImageLighting.fromPixels(Uint8List.fromList([255, 0, 0, 255]), width: 1, height: 1);
    final green = WallpaperImageLighting.fromPixels(Uint8List.fromList([0, 255, 0, 255]), width: 1, height: 1);
    expect(green.luminance, greaterThan(red.luminance));
    final sample = WallpaperImageLighting.fromPixels(
      Uint8List.fromList([
        255,
        255,
        255,
        0,
        0,
        0,
        0,
        255,
        255,
        255,
        255,
        255,
      ]),
      width: 3,
      height: 1,
    );
    expect(sample.luminance, closeTo(0.5, 0.00001));
    final transparent = WallpaperImageLighting.fromPixels(Uint8List.fromList([255, 255, 255, 0]), width: 1, height: 1);
    expect(transparent.luminance, 0);
    expect(WallpaperImageLighting.fromPixels(Uint8List(0), width: 0, height: 0).luminance, 0);
    final translucent = WallpaperImageLighting.fromPixels(
      Uint8List.fromList([
        255,
        255,
        255,
        85,
        0,
        0,
        0,
        255,
      ]),
      width: 2,
      height: 1,
    );
    expect(translucent.luminance, closeTo(0.25, 0.00001));
  });

  test('thumbnail decoding detects bright and dark encoded images', () async {
    for (final value in [16, 220]) {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawColor(ui.Color.fromARGB(255, value, value, value), ui.BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(64, 64);
      try {
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        final lighting = await WallpaperImageLighting.fromBytes(png!.buffer.asUint8List());
        expect(lighting.luminance, closeTo(value / 255, 0.005));
        expect(lighting.brightnessAt(0), value == 16 ? 1 : 0.55);
      } finally {
        image.dispose();
        picture.dispose();
      }
    }
  });

  test('invalid images report a decoding error', () async {
    await expectLater(WallpaperImageLighting.fromBytes(Uint8List.fromList([1, 2, 3])), throwsA(anything));
  });

  test('central brightness determines night dimming regardless of opposite borders', () async {
    for (final size in [const ui.Size(128, 64), const ui.Size(64, 128), const ui.Size(64, 64)]) {
      for (final centerValue in [16, 220]) {
        final borderValue = centerValue == 16 ? 220 : 16;
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        canvas.drawColor(ui.Color.fromARGB(255, borderValue, borderValue, borderValue), ui.BlendMode.src);
        canvas.drawRect(
          ui.Rect.fromLTWH(size.width / 4, size.height / 4, size.width / 2, size.height / 2),
          ui.Paint()..color = ui.Color.fromARGB(255, centerValue, centerValue, centerValue),
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(size.width.toInt(), size.height.toInt());
        try {
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          final lighting = await WallpaperImageLighting.fromBytes(png!.buffer.asUint8List());
          expect(lighting.luminance, closeTo(centerValue / 255, 0.02), reason: '$size with center $centerValue');
          expect(lighting.brightnessAt(0), centerValue == 16 ? 1 : 0.55);
          expect(lighting.brightnessAt(0.5), 1);
        } finally {
          image.dispose();
          picture.dispose();
        }
      }
    }
  });

  test('sampling rejects dimensions that do not match the pixel data', () {
    expect(() => WallpaperImageLighting.fromPixels(Uint8List(4), width: 2, height: 2), throwsArgumentError);
    expect(() => WallpaperImageLighting.fromPixels(Uint8List(4), width: -1, height: -1), throwsArgumentError);
  });
}

Future<Uint8List> _filteredPixel(ui.ColorFilter filter, ui.Color color) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 1, 1),
    ui.Paint()
      ..color = color
      ..colorFilter = filter,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(1, 1);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba);
    return data!.buffer.asUint8List();
  } finally {
    image.dispose();
    picture.dispose();
  }
}
