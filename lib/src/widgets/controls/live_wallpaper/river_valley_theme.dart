import 'package:flutter/material.dart';

/// Colors sampled from the day and night halves of the river reference.
@immutable
class RiverValleyPalette {
  const RiverValleyPalette({
    required this.skyTop,
    required this.skyMiddle,
    required this.horizon,
    required this.farMountain,
    required this.farMountainBottom,
    required this.middleMountain,
    required this.forest,
    required this.bank,
    required this.bankBottom,
    required this.river,
    required this.riverBottom,
    required this.light,
  });

  final Color skyTop;
  final Color skyMiddle;
  final Color horizon;
  final Color farMountain;
  final Color farMountainBottom;
  final Color middleMountain;
  final Color forest;
  final Color bank;
  final Color bankBottom;
  final Color river;
  final Color riverBottom;
  final Color light;

  /// Interpolates the scene during theme changes.
  RiverValleyPalette lerp(RiverValleyPalette other, double t) => RiverValleyPalette(
    skyTop: Color.lerp(skyTop, other.skyTop, t)!,
    skyMiddle: Color.lerp(skyMiddle, other.skyMiddle, t)!,
    horizon: Color.lerp(horizon, other.horizon, t)!,
    farMountain: Color.lerp(farMountain, other.farMountain, t)!,
    farMountainBottom: Color.lerp(farMountainBottom, other.farMountainBottom, t)!,
    middleMountain: Color.lerp(middleMountain, other.middleMountain, t)!,
    forest: Color.lerp(forest, other.forest, t)!,
    bank: Color.lerp(bank, other.bank, t)!,
    bankBottom: Color.lerp(bankBottom, other.bankBottom, t)!,
    river: Color.lerp(river, other.river, t)!,
    riverBottom: Color.lerp(riverBottom, other.riverBottom, t)!,
    light: Color.lerp(light, other.light, t)!,
  );
}

/// Applies the reference's warm day and blue night colors to the same landscape.
class RiverValleyTheme extends ThemeExtension<RiverValleyTheme> {
  const RiverValleyTheme({
    this.night = const RiverValleyPalette(
      skyTop: Color(0xff0a1d33),
      skyMiddle: Color(0xff0e2a47),
      horizon: Color(0xff20567c),
      farMountain: Color(0xff0f3151),
      farMountainBottom: Color(0xff1a4c72),
      middleMountain: Color(0xff11395b),
      forest: Color(0xff0e2a47),
      bank: Color(0xff0c233d),
      bankBottom: Color(0xff0a1d33),
      river: Color(0xff2b6287),
      riverBottom: Color(0xff0e2a47),
      light: Color(0xfffcf4db),
    ),
    this.day = const RiverValleyPalette(
      skyTop: Color(0xffea4b14),
      skyMiddle: Color(0xfffd8213),
      horizon: Color(0xffffb828),
      farMountain: Color(0xfff87513),
      farMountainBottom: Color(0xfffd8213),
      middleMountain: Color(0xffd3571c),
      forest: Color(0xffac3e20),
      bank: Color(0xff8b3120),
      bankBottom: Color(0xff6c281f),
      river: Color(0xffffa91e),
      riverBottom: Color(0xfff05713),
      light: Color(0xffffe16b),
    ),
  });

  final RiverValleyPalette night;
  final RiverValleyPalette day;

  /// Changes only lighting; the river, forest and mountain composition stays fixed.
  RiverValleyPalette paletteAt(double percentOfDay) {
    final hour = (percentOfDay % 1) * 24;
    if (hour < 5 || hour >= 20) return night;
    if (hour < 8) return night.lerp(day, Curves.easeInOut.transform((hour - 5) / 3));
    if (hour <= 17) return day;
    return day.lerp(night, Curves.easeInOut.transform((hour - 17) / 3));
  }

  @override
  RiverValleyTheme copyWith({RiverValleyPalette? night, RiverValleyPalette? day}) => RiverValleyTheme(night: night ?? this.night, day: day ?? this.day);

  @override
  RiverValleyTheme lerp(covariant RiverValleyTheme? other, double t) {
    if (other == null) return this;
    return RiverValleyTheme(night: night.lerp(other.night, t), day: day.lerp(other.day, t));
  }
}
