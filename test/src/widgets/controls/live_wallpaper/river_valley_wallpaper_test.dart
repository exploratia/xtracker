import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:xtracker/src/model/wallpaper_style.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_controller.dart';
import 'package:xtracker/src/widgets/administration/settings/settings_service.dart';
import 'package:xtracker/src/widgets/controls/layout/wallpaper.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/river_valley_theme.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/river_valley_wallpaper.dart';

void main() {
  test('lighting uses the warm day and blue night palettes with gradual transitions', () {
    const theme = RiverValleyTheme();
    expect(theme.paletteAt(0).skyTop, theme.night.skyTop);
    expect(theme.paletteAt(0).river, theme.night.river);
    expect(theme.paletteAt(1).skyTop, theme.night.skyTop);
    expect(theme.paletteAt(0.5).skyTop, theme.day.skyTop);
    expect(theme.paletteAt(0.5).river, theme.day.river);
    expect(theme.paletteAt(0.5).light, theme.day.light);
    expect(theme.paletteAt(0.5).skyTop.computeLuminance(), greaterThan(theme.night.skyTop.computeLuminance()));
    for (var minute = 0; minute <= 1440; minute++) {
      final colors = theme.paletteAt(minute / 1440);
      if (minute < 300 || minute >= 1200) {
        expect(colors.skyTop.b, greaterThan(colors.skyTop.r));
        expect(colors.horizon.b, greaterThan(colors.horizon.r));
      } else if (minute >= 480 && minute <= 1020) {
        expect(colors.skyTop.r, greaterThan(colors.skyTop.b));
        expect(colors.horizon.r, greaterThan(colors.horizon.b));
        expect(colors.skyTop, theme.day.skyTop);
      }
      expect(colors.river.computeLuminance(), greaterThan(colors.bank.computeLuminance()));
      if (minute > 0) {
        final previous = theme.paletteAt((minute - 1) / 1440);
        for (final (channel, previousChannel) in [
          (colors.skyTop.r, previous.skyTop.r),
          (colors.skyTop.g, previous.skyTop.g),
          (colors.skyTop.b, previous.skyTop.b),
        ]) {
          expect(channel, closeTo(previousChannel, 0.015));
        }
      }
    }
  });

  for (final size in [const Size(360, 780), const Size(768, 1024), const Size(1280, 720)]) {
    testWidgets('river valley fills $size at every time of day', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      for (final hour in [0.0, 6.5, 12.0, 18.0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: RepaintBoundary(
              key: key,
              child: RiverValleyWallpaper(percentOfDay: hour / 24),
            ),
          ),
        );
        expect(tester.getSize(find.byType(RiverValleyWallpaper)), size);
        expect(tester.takeException(), isNull);
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = (await tester.runAsync(() => boundary.toImage(pixelRatio: 1)))!;
        final pixels = (await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
        for (final x in [0, image.width ~/ 2, image.width - 1]) {
          for (final y in [0, image.height ~/ 2, image.height - 1]) {
            expect(pixels.getUint8((y * image.width + x) * 4 + 3), 255);
          }
        }
        if (hour == 0) {
          // A filled moon, rather than a crescent, occupies the reference's position.
          for (final x in [0.46, 0.50, 0.54]) {
            final offset = ((image.height * 0.325).floor() * image.width + (image.width * x).floor()) * 4;
            final light = const RiverValleyTheme().night.light;
            expect(pixels.getUint8(offset), closeTo(light.r * 255, 1));
            expect(pixels.getUint8(offset + 1), closeTo(light.g * 255, 1));
            expect(pixels.getUint8(offset + 2), closeTo(light.b * 255, 1));
          }
          final riverPixel = (image.height * 0.98).floor() * image.width + image.width ~/ 2;
          final bankPixel = (image.height * 0.98).floor() * image.width + (image.width * 0.05).floor();
          expect(pixels.getUint8(riverPixel * 4 + 2), greaterThan(pixels.getUint8(bankPixel * 4 + 2)));
          // Water stays connected through every bend, without intersecting banks.
          for (final y in [0.73, 0.75, 0.77, 0.80, 0.85, 0.90, 0.95]) {
            var riverWidth = 0;
            final row = (image.height * y).floor() * image.width;
            final bankBlue = const RiverValleyTheme().night.bank.b * 255;
            for (var x = 0; x < image.width; x++) {
              if (pixels.getUint8((row + x) * 4 + 2) > bankBlue + 10) riverWidth++;
            }
            expect(riverWidth, greaterThan(image.width * 0.02), reason: 'Continuous river at y=$y');
          }
        }
        image.dispose();
      }
    });
  }

  testWidgets('river valley is rendered across the full available surface', (tester) async {
    final controller = SettingsController(_MemorySettingsService());
    addTearDown(controller.dispose);
    await controller.updateWallpaperStyle(WallpaperStyle.riverValley);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: Wallpaper(child: SizedBox.expand())),
      ),
    );
    expect(tester.getSize(find.byType(RiverValleyWallpaper)), tester.view.physicalSize / tester.view.devicePixelRatio);
    await tester.pumpWidget(const SizedBox());
  });

  if (const bool.fromEnvironment('wallpaperPreview')) {
    testWidgets('exports river valley reference and day cycle previews', (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      for (final nightOnly in [true, false]) {
        tester.view.physicalSize = Size(nightOnly ? 360 : 1440, 780);
        await tester.pumpWidget(
          MaterialApp(
            home: RepaintBoundary(
              key: key,
              child: Row(
                children: [
                  for (final hour in nightOnly ? [0.0] : [6.5, 12.0, 18.0, 0.0]) Expanded(child: RiverValleyWallpaper(percentOfDay: hour / 24)),
                ],
              ),
            ),
          ),
        );
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
          final file = File('build/test_artifacts/river_valley_${nightOnly ? 'night' : 'preview'}.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(png.buffer.asUint8List());
          image.dispose();
        });
      }
    });
  }
}

class _MemorySettingsService extends SettingsService {
  @override
  Future<void> updateWallpaperStyle(WallpaperStyle value) async {}
}
