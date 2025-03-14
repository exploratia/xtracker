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

  static void paintGradientFilledRect(Canvas canvas, Rect rect, double rectRadius, List<Color> colors, AlignmentGeometry begin, AlignmentGeometry end,
      {List<double>? stops}) {
    final LinearGradient gradient = LinearGradient(
      colors: colors,
      stops: stops,
      begin: begin,
      end: end,
    );
    final Paint paint = Paint()..shader = gradient.createShader(rect);
    if (rectRadius > 0) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(rectRadius)), paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }
}
