import 'dart:math';

import 'package:flutter/material.dart';

/// Widget, das einen Container mit zufälligen 1- oder 2-Pixel-Sprenkeln füllt.
/// - [density]: Anzahl Sterne pro Pixelfläche (z.B. 0.0006). Höher => mehr Sterne.
/// - [starColor]: Farbe der Sterne (standard: weiß).
/// - [seed]: optionaler Random-Seed für reproduzierbare Verteilung.
/// - [child]: optionaler Inhalt über dem Sternenhimmel.
class LiveWallpaperStarrySky extends StatefulWidget {
  final double density;
  final Color starColor;
  final int? seed;
  final Widget? child;

  const LiveWallpaperStarrySky({
    super.key,
    this.density = 0.0003,
    this.starColor = Colors.white,
    this.seed,
    this.child,
  });

  @override
  State<LiveWallpaperStarrySky> createState() => _LiveWallpaperStarrySkyState();
}

class _LiveWallpaperStarrySkyState extends State<LiveWallpaperStarrySky> {
  Size _lastSize = Size.zero;
  List<_Star> _stars = [];

  void _generateIfNeeded(Size size) {
    if (size == _lastSize && _stars.isNotEmpty) return;
    _lastSize = size;
    _stars = _generateStars(size, widget.density, widget.seed);
  }

  List<_Star> _generateStars(Size size, double density, int? seed) {
    if (size.width <= 0 || size.height <= 0) return [];
    final area = size.width * size.height;
    final estimatedCount = (area * density).round();
    final rng = (seed != null) ? Random(seed) : Random();
    final List<_Star> list = List<_Star>.generate(estimatedCount, (_) {
      // Zufällige Position
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      // Größe 1 oder 2 Pixel (in logischen Pixeln)
      final s = rng.nextBool() ? 1.0 : 2.0;
      // Kleine Variation in Opazität, damit es natürlicher wirkt
      final opacity = 0.7 + rng.nextDouble() * 0.3; // 0.7 - 1.0
      return _Star(Offset(dx, dy), s, opacity);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder gibt die verfügbare Größe zuverlässig an
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      _generateIfNeeded(size);

      return CustomPaint(
        size: size,
        painter: _StarPainter(
          stars: _stars,
          starColor: widget.starColor,
        ),
        child: widget.child,
      );
    });
  }
}

class _Star {
  final Offset pos;
  final double size;
  final double opacity;

  _Star(this.pos, this.size, this.opacity);
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final Color starColor;

  _StarPainter({required this.stars, required this.starColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    // Zeichne jeden Stern als Rechteck (1x1 oder 2x2) für harte "Pixel"-Optik.
    for (final s in stars) {
      paint.color = starColor.withAlpha((s.opacity * 255).toInt());
      final rect = Rect.fromLTWH(
        s.pos.dx - (s.size / 2),
        s.pos.dy - (s.size / 2),
        s.size,
        s.size,
      );
      // Für 1px Sterne: benutze drawRect (scharf). Für 2px genauso.
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) {
    // Wenn sich die Sternliste oder Farbe ändert, neu zeichnen.
    return old.stars != stars || old.starColor != starColor;
  }
}
