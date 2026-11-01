import 'package:flutter/material.dart';

/// Atmosphere colors, including the opacity of the moon and stars.
@immutable
class MoonlitHorizonPalette {
  const MoonlitHorizonPalette({
    required this.skyTop,
    required this.skyMiddle,
    required this.horizon,
    required this.glow,
    required this.glowOuter,
    required this.moon,
    required this.moonDetail,
    required this.farRidge,
    required this.middleRidge,
    required this.foreground,
    required this.stars,
  });

  final Color skyTop;
  final Color skyMiddle;
  final Color horizon;
  final Color glow;
  final Color glowOuter;
  final Color moon;
  final Color moonDetail;
  final Color farRidge;
  final Color middleRidge;
  final Color foreground;
  final Color stars;

  /// Interpolates the complete atmosphere while keeping all geometry fixed.
  MoonlitHorizonPalette lerp(MoonlitHorizonPalette other, double t) => MoonlitHorizonPalette(
    skyTop: Color.lerp(skyTop, other.skyTop, t)!,
    skyMiddle: Color.lerp(skyMiddle, other.skyMiddle, t)!,
    horizon: Color.lerp(horizon, other.horizon, t)!,
    glow: Color.lerp(glow, other.glow, t)!,
    glowOuter: Color.lerp(glowOuter, other.glowOuter, t)!,
    moon: Color.lerp(moon, other.moon, t)!,
    moonDetail: Color.lerp(moonDetail, other.moonDetail, t)!,
    farRidge: Color.lerp(farRidge, other.farRidge, t)!,
    middleRidge: Color.lerp(middleRidge, other.middleRidge, t)!,
    foreground: Color.lerp(foreground, other.foreground, t)!,
    stars: Color.lerp(stars, other.stars, t)!,
  );
}

/// Reference dawn colors with derived daylight and cool night atmospheres.
class MoonlitHorizonTheme extends ThemeExtension<MoonlitHorizonTheme> {
  const MoonlitHorizonTheme({
    this.dawn = const MoonlitHorizonPalette(
      skyTop: Color(0xff020001),
      skyMiddle: Color(0xff650a1b),
      horizon: Color(0xffa9152d),
      glow: Color(0xfffbde80),
      glowOuter: Color(0xffd75e43),
      moon: Color(0x2aada3ab),
      moonDetail: Color(0x48450913),
      farRidge: Color(0xffc65c42),
      middleRidge: Color(0xff914339),
      foreground: Color(0xff000000),
      stars: Color(0xb3d2d2d2),
    ),
    this.day = const MoonlitHorizonPalette(
      skyTop: Color(0xff687ea2),
      skyMiddle: Color(0xffd58e94),
      horizon: Color(0xfff0b37b),
      glow: Color(0xffffefd1),
      glowOuter: Color(0xffedbd8c),
      moon: Color(0x12f1dee1),
      moonDetail: Color(0x16796370),
      farRidge: Color(0xffb88078),
      middleRidge: Color(0xff845963),
      foreground: Color(0xff3b2530),
      stars: Color(0x00d2d2d2),
    ),
    this.night = const MoonlitHorizonPalette(
      skyTop: Color(0xff080916),
      skyMiddle: Color(0xff171831),
      horizon: Color(0xff35375a),
      glow: Color(0xffa2b4d7),
      glowOuter: Color(0xff556280),
      moon: Color(0x3ca9b7d8),
      moonDetail: Color(0x5530395a),
      farRidge: Color(0xff454666),
      middleRidge: Color(0xff28253f),
      foreground: Color(0xff080915),
      stars: Color(0xffd2d2d2),
    ),
  });

  final MoonlitHorizonPalette dawn;
  final MoonlitHorizonPalette day;
  final MoonlitHorizonPalette night;

  /// Reuses the reference's warm atmosphere at both dawn and dusk.
  MoonlitHorizonPalette paletteAt(double percentOfDay) {
    final hour = (percentOfDay % 1) * 24;
    final stops = [(0.0, night), (4.0, night), (6.5, dawn), (9.0, day), (16.0, day), (18.5, dawn), (21.0, night), (24.0, night)];
    for (var i = 1; i < stops.length; i++) {
      if (hour <= stops[i].$1) {
        final previous = stops[i - 1];
        final next = stops[i];
        return previous.$2.lerp(next.$2, Curves.easeInOut.transform((hour - previous.$1) / (next.$1 - previous.$1)));
      }
    }
    return night;
  }

  @override
  MoonlitHorizonTheme copyWith({MoonlitHorizonPalette? dawn, MoonlitHorizonPalette? day, MoonlitHorizonPalette? night}) =>
      MoonlitHorizonTheme(dawn: dawn ?? this.dawn, day: day ?? this.day, night: night ?? this.night);

  @override
  MoonlitHorizonTheme lerp(covariant MoonlitHorizonTheme? other, double t) {
    if (other == null) return this;
    return MoonlitHorizonTheme(dawn: dawn.lerp(other.dawn, t), day: day.lerp(other.day, t), night: night.lerp(other.night, t));
  }
}
