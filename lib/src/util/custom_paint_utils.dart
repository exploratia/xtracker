import 'package:flutter/material.dart';

class CustomPaintUtils {
  static TextPainter textPainter() {
    return TextPainter(
      textDirection: TextDirection.ltr,
    );
  }

  static void paintGradientFilledPath(Canvas canvas, Path path, List<Color> colors, AlignmentGeometry begin, AlignmentGeometry end, {List<double>? stops}) {
    final LinearGradient gradient = LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
    final Paint paint = Paint()..shader = gradient.createShader(path.getBounds());
    canvas.drawPath(path, paint);
  }

  static void paintGradientFilledRect(Canvas canvas, Rect rect, List<Color> colors, AlignmentGeometry begin, AlignmentGeometry end, {List<double>? stops}) {
    final LinearGradient gradient = LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }
}
