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
import 'package:xtracker/src/widgets/controls/live_wallpaper/live_wallpaper.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/mountain_lake_theme.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/mountain_lake_wallpaper.dart';

void main() {
  for (final size in [const Size(360, 780), const Size(768, 1024), const Size(1280, 720)]) {
    testWidgets('fills ${size.width} x ${size.height} at every time of day', (tester) async {
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
              child: MountainLakeWallpaper(percentOfDay: hour / 24),
            ),
          ),
        );
        expect(tester.getSize(find.byType(MountainLakeWallpaper)), size);
        expect(tester.takeException(), isNull);
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = (await tester.runAsync(() => boundary.toImage(pixelRatio: 1)))!;
        final pixels = (await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
        for (final x in [0, image.width ~/ 2, image.width - 1]) {
          for (final y in [0, image.height ~/ 2, image.height - 1]) {
            expect(pixels.getUint8((y * image.width + x) * 4 + 3), 255, reason: 'Opaque at $x, $y at hour $hour');
          }
        }
        int pixelAt(double x, double y) => pixels.getUint32(((y * image.height).floor() * image.width + (x * image.width).floor()) * 4);
        final palette = const MountainLakeTheme().paletteAt(hour / 24);
        // On the right, mountains sink below the sea and expose the brightest sky color.
        for (final (y, color) in [(0.562, palette.horizon), (0.568, palette.water)]) {
          final pixelOffset = ((y * image.height).floor() * image.width + (0.72 * image.width).floor()) * 4;
          for (final (channel, value) in [(0, color.r), (1, color.g), (2, color.b)]) {
            expect(pixels.getUint8(pixelOffset + channel), closeTo(value * 255, 3), reason: 'Open sea horizon at hour $hour');
          }
        }
        // Tree bases and hill share the same fill, including where their paths overlap.
        for (final (treeX, y) in [(0.86, 0.64), (0.63, 0.68)]) {
          for (final shift in [0, 8, 16, 24]) {
            expect((pixelAt(treeX, y) >> shift) & 255, closeTo((pixelAt(0.97, y) >> shift) & 255, 1), reason: 'Continuous silhouette at hour $hour');
          }
        }
        expect(pixelAt(0.10, 0.68), isNot(pixelAt(0.97, 0.68)), reason: 'Foreground hills remain distinct');
        expect(pixelAt(0.97, 0.80), isNot(pixelAt(0.97, 0.95)), reason: 'Foreground has a vertical gradient');
        image.dispose();
      }
    });
  }

  testWidgets('selection uses the full available surface and keeps foreground interactive', (tester) async {
    final selected = SettingsController(_MemorySettingsService());
    addTearDown(selected.dispose);
    await selected.updateWallpaperStyle(WallpaperStyle.mountainLake);
    var tapped = false;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: selected,
        child: MaterialApp(
          home: Wallpaper(
            child: Center(
              child: TextButton(onPressed: () => tapped = true, child: const Text('tap')),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(MountainLakeWallpaper)), tester.view.physicalSize / tester.view.devicePixelRatio);
    await tester.tap(find.byType(TextButton));
    expect(tapped, isTrue);
    await selected.updateWallpaperStyle(WallpaperStyle.hills);
    await tester.pump();
    expect(find.byType(MountainLakeWallpaper), findsNothing);
    expect(tester.getSize(find.byType(LiveWallpaper)).height, 300);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: selected,
        child: const MaterialApp(home: Wallpaper(showWallpaper: false, child: SizedBox.expand())),
      ),
    );
    expect(find.byType(LiveWallpaper), findsNothing);
    expect(find.byType(MountainLakeWallpaper), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('day and night render with different sky colors', (tester) async {
    final key = GlobalKey();
    final skyPixels = <int>[];
    for (final time in [0.0, 0.5]) {
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: key,
            child: MountainLakeWallpaper(percentOfDay: time),
          ),
        ),
      );
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = (await tester.runAsync(() => boundary.toImage(pixelRatio: 1)))!;
      final pixels = (await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
      skyPixels.add(pixels.getUint32(0));
      image.dispose();
    }
    expect(skyPixels[0], isNot(skyPixels[1]));
  });

  if (const bool.fromEnvironment('wallpaperPreview')) {
    testWidgets('exports a visual review sheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 585);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: key,
            child: Row(
              children: [
                for (final hour in [6.5, 12.0, 18.0, 0.0]) Expanded(child: MountainLakeWallpaper(percentOfDay: hour / 24)),
              ],
            ),
          ),
        ),
      );
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        final file = File('build/test_artifacts/mountain_lake_preview.png');
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
