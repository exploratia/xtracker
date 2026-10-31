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
import 'package:xtracker/src/widgets/controls/live_wallpaper/moonlit_horizon_theme.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/moonlit_horizon_wallpaper.dart';

void main() {
  test('reference dawn, daylight and night palettes join continuously', () {
    const theme = MoonlitHorizonTheme();
    expect(theme.paletteAt(6.5 / 24).horizon, theme.dawn.horizon);
    expect(theme.paletteAt(18.5 / 24).horizon, theme.dawn.horizon);
    expect(theme.paletteAt(0.5).horizon, theme.day.horizon);
    expect(theme.paletteAt(0).horizon, theme.night.horizon);
    expect(theme.paletteAt(1).horizon, theme.night.horizon);
    expect(theme.paletteAt(0.5).stars.a, 0);
    expect(theme.paletteAt(0).stars.a, 1);
    expect(theme.paletteAt(0).moon.a, greaterThan(theme.paletteAt(0.5).moon.a));
    for (var minute = 1; minute <= 1440; minute++) {
      final previous = theme.paletteAt((minute - 1) / 1440);
      final next = theme.paletteAt(minute / 1440);
      expect(next.horizon.r, closeTo(previous.horizon.r, 0.015));
      expect(next.moon.a, closeTo(previous.moon.a, 0.015));
    }
  });

  for (final size in [const Size(360, 780), const Size(768, 1024), const Size(1280, 720)]) {
    testWidgets('scene remains opaque across the full surface at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      for (final hour in [0.0, 6.5, 12.0, 18.5]) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: RepaintBoundary(
              key: key,
              child: MoonlitHorizonWallpaper(percentOfDay: hour / 24),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = (await tester.runAsync(() => boundary.toImage(pixelRatio: 1)))!;
        final pixels = (await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
        for (final x in [0, image.width ~/ 2, image.width - 1]) {
          int alphaAt(double y) => pixels.getUint8(((image.height * y).floor() * image.width + x) * 4 + 3);
          for (final y in [0.0, 0.1, 0.5, 0.9, 0.999]) {
            expect(alphaAt(y), 255);
          }
        }
        image.dispose();
      }
    });
  }

  for (final size in [const Size(360, 780), const Size(1280, 400)]) {
    testWidgets('wallpaper fills the screen and preserves interaction at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = SettingsController(_MemorySettingsService());
      addTearDown(controller.dispose);
      await controller.updateWallpaperStyle(WallpaperStyle.moonlitHorizon);
      var tapped = false;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            home: Wallpaper(
              child: SizedBox.expand(
                child: Center(
                  child: TextButton(onPressed: () => tapped = true, child: const Text('tap')),
                ),
              ),
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byType(MoonlitHorizonWallpaper));
      expect(rect, Offset.zero & size);
      await tester.tap(find.byType(TextButton));
      expect(tapped, isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  }

  if (const bool.fromEnvironment('wallpaperPreview')) {
    testWidgets('exports full-screen moonlit horizon throughout the day', (tester) async {
      tester.view.physicalSize = const Size(1440, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: Row(
              children: [
                for (final hour in [6.5, 12.0, 18.5, 0.0])
                  Expanded(
                    child: MoonlitHorizonWallpaper(percentOfDay: hour / 24),
                  ),
              ],
            ),
          ),
        ),
      );
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        final file = File('build/test_artifacts/moonlit_horizon_preview.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(png.buffer.asUint8List());
        image.dispose();
      });
    });
  }
}

class _MemorySettingsService extends SettingsService {
  @override
  Future<void> updateWallpaperStyle(WallpaperStyle value) async {}
}
