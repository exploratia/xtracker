import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'moonlit_horizon_theme.dart';

/// A still, translucent moon above a glowing horizon and angular hill silhouettes.
class MoonlitHorizonWallpaper extends StatelessWidget {
  const MoonlitHorizonWallpaper({super.key, this.percentOfDay = 6.5 / 24});

  final double percentOfDay;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      isComplex: true,
      painter: _MoonlitHorizonPainter(
        percentOfDay,
        Theme.of(context).extension<MoonlitHorizonTheme>() ?? const MoonlitHorizonTheme(),
      ),
      child: const SizedBox.expand(),
    ),
  );
}

class _MoonlitHorizonPainter extends CustomPainter {
  const _MoonlitHorizonPainter(this.percentOfDay, this.sceneTheme);

  final double percentOfDay;
  final MoonlitHorizonTheme sceneTheme;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final colors = sceneTheme.paletteAt(percentOfDay);
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
          colors: [colors.skyTop, colors.skyTop, colors.skyMiddle, colors.horizon],
          stops: const [0, 0.18, 0.56, 0.85],
        ).createShader(bounds),
    );
    _drawStars(canvas, size, colors);
    final radius = math.min(width * 0.445, height * 0.515);
    _drawMoon(canvas, Rect.fromCircle(center: Offset(width * 0.5, height * 0.585), radius: radius), colors);

    final glow = Rect.fromCircle(center: Offset(width * 0.5, height * 0.82), radius: math.min(width * 0.53, height * 0.48));
    canvas.drawOval(
      glow,
      Paint()
        ..shader = RadialGradient(
          colors: [colors.glow, colors.glowOuter.withValues(alpha: 0.85), colors.horizon.withValues(alpha: 0)],
          stops: const [0, 0.36, 1],
        ).createShader(glow),
    );

    _drawRidge(canvas, size, colors.farRidge, const [
      Offset(0, 0.77),
      Offset(0.08, 0.75),
      Offset(0.20, 0.786),
      Offset(0.32, 0.755),
      Offset(0.47, 0.788),
      Offset(0.60, 0.782),
      Offset(0.71, 0.758),
      Offset(0.82, 0.79),
      Offset(0.92, 0.754),
      Offset(1, 0.78),
    ]);
    _drawRidge(canvas, size, colors.middleRidge, const [
      Offset(0, 0.81),
      Offset(0.16, 0.726),
      Offset(0.23, 0.77),
      Offset(0.33, 0.80),
      Offset(0.44, 0.81),
      Offset(0.55, 0.83),
      Offset(0.65, 0.79),
      Offset(0.75, 0.765),
      Offset(0.82, 0.792),
      Offset(0.93, 0.77),
      Offset(1, 0.786),
    ]);
    final foreground = Path()
      ..moveTo(0, height * 0.91)
      ..lineTo(width * 0.085, height * 0.884)
      ..lineTo(width * 0.17, height * 0.879)
      ..lineTo(width * 0.27, height * 0.842)
      ..lineTo(width * 0.34, height * 0.834)
      ..lineTo(width * 0.405, height * 0.789)
      ..lineTo(width * 0.445, height * 0.772)
      ..lineTo(width * 0.478, height * 0.801)
      ..lineTo(width * 0.55, height * 0.835)
      ..lineTo(width * 0.61, height * 0.848)
      ..lineTo(width * 0.68, height * 0.845)
      ..lineTo(width * 0.735, height * 0.869)
      ..lineTo(width * 0.773, height * 0.824)
      ..lineTo(width * 0.838, height * 0.802)
      ..lineTo(width * 0.895, height * 0.79)
      ..lineTo(width * 0.925, height * 0.811)
      ..lineTo(width, height * 0.836)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    for (final (x, base, treeHeight) in [
      (0.055, 0.90, 0.11),
      (0.10, 0.894, 0.075),
      (0.145, 0.89, 0.095),
      (0.185, 0.879, 0.065),
      (0.815, 0.819, 0.095),
      (0.873, 0.803, 0.128),
      (0.938, 0.825, 0.08),
    ]) {
      foreground.addPath(_fir(Offset(width * x, height * base), math.min(height * treeHeight, unit * treeHeight * 1.8)), Offset.zero);
    }
    canvas.drawPath(foreground, Paint()..color = colors.foreground);
    canvas.restore();
  }

  void _drawMoon(Canvas canvas, Rect disk, MoonlitHorizonPalette colors) {
    canvas.save();
    canvas.clipPath(Path()..addOval(disk));
    canvas.drawOval(
      disk,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.moon,
            colors.moon.withValues(alpha: colors.moon.a * 0.15),
          ],
        ).createShader(disk),
    );
    // Broad, irregular lunar seas keep the translucent moon recognizable without a bitmap.
    const patches = [
      [
        Offset(0.12, 0.27),
        Offset(0.20, 0.16),
        Offset(0.27, 0.13),
        Offset(0.31, 0.16),
        Offset(0.38, 0.16),
        Offset(0.35, 0.20),
        Offset(0.29, 0.21),
        Offset(0.27, 0.25),
        Offset(0.22, 0.24),
        Offset(0.19, 0.35),
        Offset(0.16, 0.31),
      ],
      [
        Offset(0.16, 0.32),
        Offset(0.20, 0.27),
        Offset(0.28, 0.29),
        Offset(0.30, 0.26),
        Offset(0.38, 0.27),
        Offset(0.40, 0.31),
        Offset(0.46, 0.30),
        Offset(0.50, 0.34),
        Offset(0.45, 0.36),
        Offset(0.48, 0.40),
        Offset(0.42, 0.43),
        Offset(0.39, 0.42),
        Offset(0.36, 0.48),
        Offset(0.31, 0.49),
        Offset(0.32, 0.54),
        Offset(0.26, 0.54),
        Offset(0.25, 0.48),
        Offset(0.20, 0.47),
        Offset(0.22, 0.41),
        Offset(0.17, 0.40),
        Offset(0.19, 0.36),
      ],
      [
        Offset(0.38, 0.10),
        Offset(0.43, 0.11),
        Offset(0.48, 0.07),
        Offset(0.48, 0.12),
        Offset(0.55, 0.15),
        Offset(0.49, 0.17),
        Offset(0.49, 0.21),
        Offset(0.44, 0.18),
        Offset(0.40, 0.22),
        Offset(0.36, 0.20),
        Offset(0.40, 0.16),
      ],
      [
        Offset(0.52, 0.13),
        Offset(0.60, 0.17),
        Offset(0.68, 0.17),
        Offset(0.69, 0.22),
        Offset(0.73, 0.25),
        Offset(0.70, 0.29),
        Offset(0.75, 0.32),
        Offset(0.68, 0.34),
        Offset(0.65, 0.30),
        Offset(0.60, 0.31),
        Offset(0.57, 0.26),
        Offset(0.51, 0.25),
        Offset(0.53, 0.20),
        Offset(0.49, 0.18),
      ],
      [
        Offset(0.66, 0.34),
        Offset(0.71, 0.35),
        Offset(0.75, 0.29),
        Offset(0.77, 0.34),
        Offset(0.82, 0.36),
        Offset(0.78, 0.39),
        Offset(0.81, 0.42),
        Offset(0.75, 0.44),
        Offset(0.72, 0.49),
        Offset(0.68, 0.47),
        Offset(0.64, 0.43),
        Offset(0.67, 0.40),
      ],
      [Offset(0.82, 0.42), Offset(0.89, 0.46), Offset(0.92, 0.56), Offset(0.85, 0.58), Offset(0.80, 0.52)],
      [Offset(0.11, 0.46), Offset(0.20, 0.40), Offset(0.21, 0.53), Offset(0.16, 0.64), Offset(0.10, 0.61)],
      [Offset(0.42, 0.48), Offset(0.55, 0.47), Offset(0.59, 0.55), Offset(0.55, 0.63), Offset(0.46, 0.58), Offset(0.37, 0.59)],
    ];
    final detail = Paint()..color = colors.moonDetail;
    for (final points in patches) {
      Offset position(Offset point) => Offset(disk.left + point.dx * disk.width, disk.top + point.dy * disk.height);
      final path = Path()..moveTo(position(points.first).dx, position(points.first).dy);
      for (var i = 1; i <= points.length; i++) {
        final control = position(points[i % points.length]);
        final next = position(points[(i + 1) % points.length]);
        path.quadraticBezierTo(control.dx, control.dy, control.dx * 0.88 + next.dx * 0.12, control.dy * 0.88 + next.dy * 0.12);
      }
      canvas.drawPath(path..close(), detail);
    }
    for (final (x, y, radius) in [(0.63, 0.31, 0.018), (0.75, 0.44, 0.026), (0.33, 0.55, 0.022)]) {
      canvas.drawCircle(
        Offset(disk.left + disk.width * x, disk.top + disk.height * y),
        disk.width * radius,
        Paint()
          ..color = colors.moon
          ..style = PaintingStyle.stroke
          ..strokeWidth = disk.width * 0.0015,
      );
    }
    canvas.restore();
  }

  void _drawStars(Canvas canvas, Size size, MoonlitHorizonPalette colors) {
    if (colors.stars.a == 0) return;
    final unit = math.min(size.width, size.height);
    for (var i = 0; i < 28; i++) {
      final x = ((i * 73 + 19) % 211) / 211;
      final y = 0.07 + ((i * 41 + 7) % 127) / 127 * 0.47;
      canvas.drawCircle(Offset(x * size.width, y * size.height), unit * (i % 5 == 0 ? 0.0025 : 0.0013), Paint()..color = colors.stars);
    }
    final tail = Offset(size.width * 0.93, size.height * 0.35);
    final head = Offset(size.width * 0.82, size.height * 0.40);
    canvas.drawLine(
      tail,
      head,
      Paint()
        ..strokeWidth = unit * 0.003
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [colors.stars.withValues(alpha: 0), colors.stars],
        ).createShader(Rect.fromPoints(tail, head)),
    );
  }

  void _drawRidge(Canvas canvas, Size size, Color color, List<Offset> points) {
    final path = Path()..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }
    canvas.drawPath(
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  Path _fir(Offset base, double height) {
    final path = Path()..moveTo(base.dx, base.dy - height);
    for (var i = 1; i <= 7; i++) {
      final y = base.dy - height + height * i / 7;
      final spread = height * (0.025 + i * 0.026);
      path.lineTo(base.dx + spread, y);
      path.lineTo(base.dx + spread * 0.5, y - height * 0.03);
    }
    for (var i = 7; i >= 1; i--) {
      final y = base.dy - height + height * i / 7;
      final spread = height * (0.025 + i * 0.026);
      path.lineTo(base.dx - spread * 0.5, y - height * 0.03);
      path.lineTo(base.dx - spread, y);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _MoonlitHorizonPainter oldDelegate) => oldDelegate.percentOfDay != percentOfDay || oldDelegate.sceneTheme != sceneTheme;
}
