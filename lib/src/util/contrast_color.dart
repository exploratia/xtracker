import 'dart:math';

import 'package:flutter/material.dart';

/// Candidate colors: generated only once and reused
class ContrastColor {
  static final List<Color> colorCandidates = _generateCandidates();

  static List<Color> _generateCandidates() {
    final hues = List.generate(12, (i) => i * 30.0); // 12 hue steps (0..330)
    final lightnessLevels = [0.2, 0.4, 0.6, 0.8, 1.0];
    const saturation = 0.9;

    return [
      for (final h in hues)
        for (final l in lightnessLevels) HSLColor.fromAHSL(1.0, h, saturation, l).toColor()
    ];
  }

  /// Finds the color with the highest minimal contrast against existing colors
  static Color findMaxContrastColor(Iterable<Color> existingColors) {
    Color bestColor = Colors.black;
    double bestMinDist = -1;

    for (final candidate in colorCandidates) {
      double minDist = double.infinity;
      for (final existing in existingColors) {
        final dist = _colorDistance(candidate, existing);
        if (dist < minDist) minDist = dist;
      }

      if (minDist > bestMinDist) {
        bestMinDist = minDist;
        bestColor = candidate;
      }
    }

    return bestColor;
  }

  /// Distance between two colors in Lab color space
  static double _colorDistance(Color c1, Color c2) {
    final lab1 = _rgbToLab(c1);
    final lab2 = _rgbToLab(c2);

    final dl = lab1[0] - lab2[0];
    final da = lab1[1] - lab2[1];
    final db = lab1[2] - lab2[2];
    return sqrt(dl * dl + da * da + db * db);
  }

  /// RGB → Lab conversion
  static List<double> _rgbToLab(Color color) {
    // Normalize RGB
    double r = color.r;
    double g = color.g;
    double b = color.b;

    // Apply gamma correction
    r = r > 0.04045 ? pow((r + 0.055) / 1.055, 2.4).toDouble() : r / 12.92;
    g = g > 0.04045 ? pow((g + 0.055) / 1.055, 2.4).toDouble() : g / 12.92;
    b = b > 0.04045 ? pow((b + 0.055) / 1.055, 2.4).toDouble() : b / 12.92;

    // Convert sRGB to XYZ
    double x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047;
    double y = (r * 0.2126 + g * 0.7152 + b * 0.0722) / 1.00000;
    double z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883;

    // Convert XYZ to Lab
    double f(double t) => t > 0.008856 ? pow(t, 1 / 3).toDouble() : (7.787 * t + 16 / 116);

    final fx = f(x);
    final fy = f(y);
    final fz = f(z);

    final l = 116 * fy - 16;
    final a = 500 * (fx - fy);
    final b2 = 200 * (fy - fz);

    return [l, a, b2];
  }
}
