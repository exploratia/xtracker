import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'mountain_lake_theme.dart';
import 'wallpaper_day_cycle.dart';

/// A lightweight vector landscape that only repaints when its time or theme changes.
class MountainLakeWallpaper extends StatelessWidget {
  const MountainLakeWallpaper({super.key, this.percentOfDay = 0.5});

  final double percentOfDay;

  @override
  Widget build(BuildContext context) {
    final sceneTheme = Theme.of(context).extension<MountainLakeTheme>() ?? const MountainLakeTheme();
    return RepaintBoundary(
      child: CustomPaint(
        painter: _MountainLakePainter(WallpaperDayCycle(percentOfDay), sceneTheme),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MountainLakePainter extends CustomPainter {
  const _MountainLakePainter(this.cycle, this.sceneTheme);

  final WallpaperDayCycle cycle;
  final MountainLakeTheme sceneTheme;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final colors = sceneTheme.paletteAt(cycle.percentOfDay);
    final width = size.width;
    final height = size.height;
    final unit = math.min(width, height);
    final bounds = Offset.zero & size;
    final horizonY = height * 0.565;
    canvas.save();
    canvas.clipRect(bounds);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.skyTop, colors.horizon],
        ).createShader(Rect.fromLTRB(0, 0, width, horizonY)),
    );

    _drawStars(canvas, size, colors);
    _drawSkyBody(canvas, size, colors, cycle.sunProgress, cycle.sunOpacity, moon: false);
    _drawSkyBody(canvas, size, colors, cycle.moonProgress, cycle.moonOpacity, moon: true);

    _drawRidge(canvas, size, colors.farMountain, colors.farMountainBottom, const [
      Offset(-0.05, 0.12),
      Offset(0.09, 0.245),
      Offset(0.14, 0.21),
      Offset(0.255, 0.35),
      Offset(0.29, 0.325),
      Offset(0.36, 0.405),
      Offset(0.40, 0.387),
      Offset(0.56, 0.52),
      Offset(0.62, 0.55),
      Offset(0.69, 0.586),
      Offset(0.79, 0.64),
      Offset(1.05, 0.72),
    ]);
    _drawRidge(canvas, size, colors.middleMountain, colors.middleMountainBottom, const [
      Offset(-0.05, 0.245),
      Offset(0.055, 0.315),
      Offset(0.12, 0.303),
      Offset(0.205, 0.375),
      Offset(0.265, 0.29),
      Offset(0.315, 0.31),
      Offset(0.40, 0.435),
      Offset(0.445, 0.41),
      Offset(0.50, 0.47),
      Offset(0.63, 0.575),
      Offset(0.74, 0.63),
      Offset(1.05, 0.79),
    ]);
    _drawRidge(canvas, size, colors.nearMountain, colors.nearMountainBottom, const [
      Offset(-0.05, 0.365),
      Offset(0.045, 0.305),
      Offset(0.10, 0.322),
      Offset(0.21, 0.405),
      Offset(0.265, 0.386),
      Offset(0.31, 0.41),
      Offset(0.43, 0.505),
      Offset(0.50, 0.565),
      Offset(0.58, 0.616),
      Offset(1.05, 0.83),
    ]);

    final lake = Rect.fromLTRB(0, horizonY, width, height);
    canvas.drawRect(
      lake,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.water, colors.waterBottom],
        ).createShader(Rect.fromLTRB(0, horizonY, width, height * 0.79)),
    );
    _drawReflections(canvas, size, colors);

    final treeHeight = math.min(height * 0.245, unit * 0.5);
    final leftBank = Path()
      ..moveTo(0, height * 0.635)
      ..cubicTo(width * 0.17, height * 0.638, width * 0.32, height * 0.698, width * 0.54, height * 0.745)
      ..lineTo(width * 0.54, height)
      ..lineTo(0, height)
      ..close();
    leftBank.addPath(_pine(Offset(width * 0.10, height * 0.655), treeHeight * 0.5), Offset.zero);
    _drawSilhouette(canvas, bounds, leftBank, colors.bank, colors.bankBottom);

    // Match the foliage's winding direction so overlapping contours remain solid.
    final rightBank = Path()
      ..moveTo(0, height * 0.79)
      ..cubicTo(width * 0.14, height * 0.749, width * 0.27, height * 0.735, width * 0.47, height * 0.697)
      ..cubicTo(width * 0.68, height * 0.65, width * 0.83, height * 0.62, width, height * 0.60)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    rightBank.addPath(_pine(Offset(width * 0.63, height * 0.687), treeHeight * 0.73), Offset.zero);
    rightBank.addPath(_pine(Offset(width * 0.86, height * 0.644), treeHeight), Offset.zero);
    rightBank.addPath(_pine(Offset(width * 1.015, height * 0.635), treeHeight * 0.62), Offset.zero);
    _drawSilhouette(canvas, bounds, rightBank, colors.trees, colors.treesBottom);
    canvas.restore();
  }

  void _drawSilhouette(Canvas canvas, Rect bounds, Path path, Color top, Color bottom) {
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, top, bottom],
          stops: const [0, 0.58, 1],
        ).createShader(bounds),
    );
  }

  void _drawRidge(Canvas canvas, Size size, Color top, Color bottom, List<Offset> points) {
    final path = Path()..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    // Small rounded corners retain the paper-cut silhouette without harsh zigzags.
    for (var i = 1; i < points.length - 1; i++) {
      final point = points[i];
      final next = points[i + 1];
      path.quadraticBezierTo(
        point.dx * size.width,
        point.dy * size.height,
        (point.dx * 0.85 + next.dx * 0.15) * size.width,
        (point.dy * 0.85 + next.dy * 0.15) * size.height,
      );
    }
    path.lineTo(points.last.dx * size.width, points.last.dy * size.height);
    path.lineTo(size.width * 1.05, size.height);
    path.lineTo(-size.width * 0.05, size.height);
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(Rect.fromLTRB(0, size.height * 0.18, size.width, size.height * 0.58)),
    );
  }

  void _drawStars(Canvas canvas, Size size, MountainLakePalette colors) {
    if (cycle.starOpacity <= 0) return;
    final unit = math.min(size.width, size.height);
    for (var i = 0; i < 36; i++) {
      // Fixed arithmetic positions avoid allocations, random flicker and timers.
      final x = ((i * 73 + 19) % 211) / 211;
      final y = ((i * 41 + 7) % 127) / 127;
      final alpha = cycle.starOpacity * (0.25 + (i % 4) * 0.12) * (1 - y * 0.6);
      canvas.drawCircle(
        Offset(x * size.width, (0.035 + y * 0.41) * size.height),
        unit * (i % 5 == 0 ? 0.0022 : 0.0013),
        Paint()..color = colors.light.withValues(alpha: alpha),
      );
    }
  }

  void _drawSkyBody(Canvas canvas, Size size, MountainLakePalette colors, double progress, double opacity, {required bool moon}) {
    if (opacity <= 0) return;
    final radius = math.min(size.width, size.height) * 0.095;
    final center = Offset(size.width * (0.16 + progress * 0.68), size.height * (0.55 - cycle.elevation(progress) * 0.30));
    final glow = Rect.fromCircle(center: center, radius: radius * 1.8);
    canvas.drawCircle(
      center,
      radius * 1.8,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colors.light.withValues(alpha: opacity * (moon ? 0.16 : 0.38)),
            colors.light.withValues(alpha: opacity * (moon ? 0.04 : 0.17)),
            colors.light.withValues(alpha: 0),
          ],
          stops: const [0, 0.6, 1],
        ).createShader(glow),
    );
    if (!moon) {
      canvas.drawCircle(center, radius * 1.3, Paint()..color = colors.light.withValues(alpha: opacity * 0.12));
      canvas.drawCircle(center, radius * 1.15, Paint()..color = colors.light.withValues(alpha: opacity * 0.14));
    }
    final disk = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    final body = moon
        ? Path.combine(
            PathOperation.difference,
            disk,
            Path()..addOval(Rect.fromCircle(center: center + Offset(radius * 0.65, -radius * 0.35), radius: radius * 0.95)),
          )
        : disk;
    canvas.drawPath(body, Paint()..color = colors.light.withValues(alpha: opacity * 0.94));
  }

  void _drawReflections(Canvas canvas, Size size, MountainLakePalette colors) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    final progress = cycle.sunOpacity > 0 ? cycle.sunProgress : cycle.moonProgress;
    final lightX = size.width * (0.16 + progress * 0.68);
    for (var i = 0; i < 16; i++) {
      final y = size.height * (0.577 + i * 0.008);
      final halfWidth = size.width * (0.025 + i * 0.003);
      final x = lightX + math.sin(i * 2.4) * size.width * 0.024;
      paint.color = colors.light.withValues(alpha: 0.35 * (1 - i / 19));
      paint.strokeWidth = math.min(size.width, size.height) * (i.isEven ? 0.003 : 0.0015);
      canvas.drawLine(Offset(x - halfWidth, y), Offset(x + halfWidth, y), paint);
    }
    paint.color = colors.light.withValues(alpha: 0.25);
    paint.strokeWidth = math.min(size.width, size.height) * 0.002;
    for (var i = 0; i < 9; i++) {
      final x = ((i * 47 + 11) % 101) / 101 * size.width;
      final y = size.height * (0.59 + (i % 4) * 0.026);
      canvas.drawLine(Offset(x, y), Offset(x + size.width * 0.07, y), paint);
    }
  }

  Path _pine(Offset base, double height) {
    final path = Path()..moveTo(base.dx, base.dy - height);
    const branches = [
      Offset(0.085, 0.20),
      Offset(0.045, 0.18),
      Offset(0.15, 0.35),
      Offset(0.09, 0.32),
      Offset(0.22, 0.53),
      Offset(0.13, 0.49),
      Offset(0.29, 0.72),
      Offset(0.19, 0.68),
      Offset(0.36, 0.91),
      Offset(0.28, 0.88),
      Offset(0.38, 1.04),
    ];
    for (final point in branches) {
      path.lineTo(base.dx + point.dx * height, base.dy - height + point.dy * height);
    }
    for (final point in branches.reversed) {
      path.lineTo(base.dx - point.dx * height, base.dy - height + point.dy * height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _MountainLakePainter oldDelegate) =>
      oldDelegate.cycle.percentOfDay != cycle.percentOfDay || oldDelegate.sceneTheme != sceneTheme;
}
