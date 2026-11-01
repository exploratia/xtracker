import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/widgets/controls/live_wallpaper/live_wallpaper.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('sky and ground reach both edges in ${brightness.name} mode', (tester) async {
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: const SizedBox(width: 400, height: 300, child: LiveWallpaper()),
            ),
          ),
        ),
      );
      final boundary = boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = (await tester.runAsync(() => boundary.toImage(pixelRatio: 1)))!;
      addTearDown(image.dispose);
      final pixels = (await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.rawRgba)))!;
      for (final y in [180, 220]) {
        for (final channel in [0, 1, 2, 3]) {
          int pixel(int x) => pixels.getUint8((y * image.width + x) * 4 + channel);
          // Gradient dithering can differ by one channel value between pixels.
          expect(pixel(0), closeTo(pixel(1), 1), reason: 'Left edge at y=$y, channel=$channel');
          expect(pixel(image.width - 1), closeTo(pixel(image.width - 2), 1), reason: 'Right edge at y=$y, channel=$channel');
        }
      }
    });
  }
}
