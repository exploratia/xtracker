import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'river_valley_theme.dart';
import 'wallpaper_day_cycle.dart';

/// Blue mountain silhouettes, a winding river and a full moon, drawn as vectors.
class RiverValleyWallpaper extends StatelessWidget {
  const RiverValleyWallpaper({super.key, this.percentOfDay = 0});

  final double percentOfDay;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _RiverValleyPainter(
        WallpaperDayCycle(percentOfDay),
        Theme.of(context).extension<RiverValleyTheme>() ?? const RiverValleyTheme(),
      ),
      child: const SizedBox.expand(),
    ),
  );
}

class _RiverValleyPainter extends CustomPainter {
  const _RiverValleyPainter(this.cycle, this.sceneTheme);

  final WallpaperDayCycle cycle;
  final RiverValleyTheme sceneTheme;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final colors = sceneTheme.paletteAt(cycle.percentOfDay);
    final bounds = Offset.zero & size;
    final width = size.width;
    final height = size.height;
    final unit = math.min(width, height);
    canvas.save();
    canvas.clipRect(bounds);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.skyTop, colors.skyMiddle, colors.horizon],
          stops: const [0, 0.28, 0.68],
        ).createShader(bounds),
    );
    _drawStars(canvas, size, colors);
    _drawSkyBody(canvas, size, colors, cycle.moonProgress, cycle.moonOpacity);
    _drawSkyBody(canvas, size, colors, cycle.sunProgress, cycle.sunOpacity);

    // Smooth, uneven ridges follow the reference's broad mountain silhouettes.
    final farMountains = Path()
      ..moveTo(-0.03, 0.49)
      ..cubicTo(0.04, 0.47, 0.12, 0.43, 0.18, 0.434)
      ..cubicTo(0.26, 0.43, 0.33, 0.53, 0.43, 0.545)
      ..cubicTo(0.50, 0.562, 0.55, 0.53, 0.61, 0.53)
      ..cubicTo(0.68, 0.529, 0.73, 0.59, 0.80, 0.595)
      ..cubicTo(0.87, 0.606, 0.94, 0.562, 1.04, 0.547)
      ..lineTo(1.04, 1)
      ..lineTo(-0.03, 1)
      ..close();
    canvas.drawPath(
      _scale(farMountains, size),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.farMountain, colors.farMountainBottom],
        ).createShader(Rect.fromLTRB(0, height * 0.43, width, height * 0.73)),
    );

    final middleMountains = Path()
      ..moveTo(-0.05, 0.60)
      ..cubicTo(0.06, 0.58, 0.13, 0.53, 0.20, 0.551)
      ..cubicTo(0.29, 0.57, 0.32, 0.618, 0.42, 0.636)
      ..cubicTo(0.51, 0.653, 0.56, 0.613, 0.62, 0.64)
      ..cubicTo(0.76, 0.682, 0.91, 0.701, 1.05, 0.666)
      ..lineTo(1.05, 1)
      ..lineTo(-0.05, 1)
      ..close();
    canvas.drawPath(_scale(middleMountains, size), Paint()..color = colors.middleMountain);

    final forest = _scale(
      Path()
        ..moveTo(0, 0.66)
        ..cubicTo(0.18, 0.62, 0.29, 0.69, 0.42, 0.684)
        ..cubicTo(0.62, 0.682, 0.79, 0.715, 1, 0.72)
        ..lineTo(1, 1)
        ..lineTo(0, 1)
        ..close(),
      size,
    );
    for (final (x, treeHeight) in [(0.37, 0.07), (0.42, 0.095), (0.47, 0.06), (0.51, 0.075), (0.55, 0.055), (0.59, 0.045)]) {
      forest.addPath(_fir(Offset(width * x, height * 0.715), math.min(height * treeHeight, unit * treeHeight * 2)), Offset.zero);
    }
    canvas.drawPath(forest, Paint()..color = colors.forest);

    final ground = _scale(
      Path()
        ..moveTo(0, 0.69)
        ..cubicTo(0.28, 0.68, 0.48, 0.695, 0.69, 0.70)
        ..cubicTo(0.83, 0.703, 0.94, 0.711, 1, 0.71)
        ..lineTo(1, 1)
        ..lineTo(0, 1)
        ..close(),
      size,
    );
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [colors.bank, colors.bankBottom],
      ).createShader(Rect.fromLTRB(0, height * 0.69, width, height));
    canvas.drawPath(ground, groundPaint);
    _drawRiver(canvas, size, colors);

    final frontBank = _scale(
      Path()
        ..moveTo(0, 0.70)
        ..cubicTo(0.16, 0.718, 0.34, 0.753, 0.43, 0.785)
        ..cubicTo(0.48, 0.81, 0.31, 0.83, 0.22, 0.86)
        ..cubicTo(0.14, 0.88, 0.07, 0.91, 0, 0.94)
        ..close(),
      size,
    );
    final treeHeight = math.min(height * 0.265, unit * 0.56);
    frontBank.addPath(_fir(Offset(width * 0.115, height * 0.777), treeHeight), Offset.zero);
    frontBank.addPath(_fir(Offset(width * 0.28, height * 0.788), treeHeight * 0.85), Offset.zero);
    canvas.drawPath(frontBank, Paint()..color = colors.bankBottom);
    canvas.restore();
  }

  void _drawRiver(Canvas canvas, Size size, RiverValleyPalette colors) {
    // Both banks are one closed path, widening naturally towards the viewer.
    final river = Path()
      ..moveTo(0.69, 0.698)
      ..cubicTo(0.86, 0.702, 1.01, 0.718, 0.93, 0.734)
      ..cubicTo(0.88, 0.745, 0.68, 0.746, 0.63, 0.774)
      ..cubicTo(0.60, 0.799, 0.98, 0.812, 0.95, 0.852)
      ..cubicTo(0.93, 0.893, 0.61, 0.924, 0.67, 0.963)
      ..cubicTo(0.70, 0.982, 0.78, 0.997, 0.84, 1.01)
      ..lineTo(0.30, 1.01)
      ..cubicTo(0.10, 0.951, 0.23, 0.914, 0.49, 0.879)
      ..cubicTo(0.81, 0.836, 0.47, 0.824, 0.49, 0.782)
      ..cubicTo(0.51, 0.749, 0.80, 0.738, 0.87, 0.723)
      ..cubicTo(0.94, 0.710, 0.79, 0.707, 0.69, 0.698)
      ..close();
    canvas.drawPath(
      _scale(river, size),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.river, colors.riverBottom],
        ).createShader(Rect.fromLTRB(0, size.height * 0.7, size.width, size.height)),
    );
  }

  void _drawSkyBody(Canvas canvas, Size size, RiverValleyPalette colors, double progress, double opacity) {
    if (opacity <= 0) return;
    final radius = math.min(math.min(size.width, size.height) * 0.155, size.height * 0.09);
    final center = Offset(size.width * (0.22 + progress * 0.56), size.height * (0.58 - cycle.elevation(progress) * 0.255));
    final glow = Rect.fromCircle(center: center, radius: radius * 1.5);
    canvas.drawCircle(
      center,
      radius * 1.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colors.light.withValues(alpha: opacity * 0.12),
            colors.light.withValues(alpha: 0),
          ],
        ).createShader(glow),
    );
    canvas.drawCircle(center, radius, Paint()..color = colors.light.withValues(alpha: opacity));
  }

  void _drawStars(Canvas canvas, Size size, RiverValleyPalette colors) {
    final opacity = cycle.starOpacity;
    if (opacity <= 0) return;
    final unit = math.min(size.width, size.height);
    final paint = Paint()..color = colors.light.withValues(alpha: opacity * 0.7);
    for (final star in const [Offset(0.145, 0.273), Offset(0.828, 0.228), Offset(0.78, 0.471), Offset(0.43, 0.37), Offset(0.91, 0.12)]) {
      canvas.drawCircle(Offset(star.dx * size.width, star.dy * size.height), unit * 0.0027, paint);
    }
    final center = Offset(size.width * 0.304, size.height * 0.096);
    final radius = unit * 0.009;
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx + radius * 0.65, center.dy)
        ..lineTo(center.dx, center.dy + radius)
        ..lineTo(center.dx - radius * 0.65, center.dy)
        ..close(),
      paint,
    );
    final tail = Offset(size.width * 0.82, size.height * 0.095);
    final head = Offset(size.width * 0.56, size.height * 0.165);
    canvas.drawLine(
      tail,
      head,
      Paint()
        ..strokeWidth = unit * 0.004
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            colors.river.withValues(alpha: 0),
            colors.river.withValues(alpha: opacity * 0.65),
          ],
        ).createShader(Rect.fromPoints(tail, head)),
    );
  }

  Path _fir(Offset root, double height) {
    final path = Path()..moveTo(root.dx, root.dy - height);
    const branches = [
      Offset(0.07, 0.20),
      Offset(0.035, 0.18),
      Offset(0.115, 0.33),
      Offset(0.065, 0.30),
      Offset(0.16, 0.47),
      Offset(0.09, 0.43),
      Offset(0.205, 0.61),
      Offset(0.12, 0.57),
      Offset(0.25, 0.76),
      Offset(0.16, 0.72),
      Offset(0.3, 0.91),
      Offset(0.21, 0.87),
      Offset(0.29, 1.03),
    ];
    for (final point in branches) {
      path.lineTo(root.dx + point.dx * height, root.dy - height + point.dy * height);
    }
    for (final point in branches.reversed) {
      path.lineTo(root.dx - point.dx * height, root.dy - height + point.dy * height);
    }
    return path..close();
  }

  Path _scale(Path path, Size size) => path.transform(Matrix4.diagonal3Values(size.width, size.height, 1).storage);

  @override
  bool shouldRepaint(covariant _RiverValleyPainter oldDelegate) => oldDelegate.cycle.percentOfDay != cycle.percentOfDay || oldDelegate.sceneTheme != sceneTheme;
}
