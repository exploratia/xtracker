import 'package:flutter/material.dart';

/// Semantic colors for one lighting condition of the mountain lake.
@immutable
class MountainLakePalette {
  const MountainLakePalette({
    required this.skyTop,
    required this.horizon,
    required this.farMountain,
    required this.farMountainBottom,
    required this.middleMountain,
    required this.middleMountainBottom,
    required this.nearMountain,
    required this.nearMountainBottom,
    required this.water,
    required this.waterBottom,
    required this.bank,
    required this.bankBottom,
    required this.trees,
    required this.treesBottom,
    required this.light,
  });

  final Color skyTop;
  final Color horizon;
  final Color farMountain;
  final Color farMountainBottom;
  final Color middleMountain;
  final Color middleMountainBottom;
  final Color nearMountain;
  final Color nearMountainBottom;
  final Color water;
  final Color waterBottom;
  final Color bank;
  final Color bankBottom;
  final Color trees;
  final Color treesBottom;
  final Color light;

  /// Interpolates all scene colors together for a continuous day cycle.
  MountainLakePalette lerp(MountainLakePalette other, double t) => MountainLakePalette(
    skyTop: Color.lerp(skyTop, other.skyTop, t)!,
    horizon: Color.lerp(horizon, other.horizon, t)!,
    farMountain: Color.lerp(farMountain, other.farMountain, t)!,
    farMountainBottom: Color.lerp(farMountainBottom, other.farMountainBottom, t)!,
    middleMountain: Color.lerp(middleMountain, other.middleMountain, t)!,
    middleMountainBottom: Color.lerp(middleMountainBottom, other.middleMountainBottom, t)!,
    nearMountain: Color.lerp(nearMountain, other.nearMountain, t)!,
    nearMountainBottom: Color.lerp(nearMountainBottom, other.nearMountainBottom, t)!,
    water: Color.lerp(water, other.water, t)!,
    waterBottom: Color.lerp(waterBottom, other.waterBottom, t)!,
    bank: Color.lerp(bank, other.bank, t)!,
    bankBottom: Color.lerp(bankBottom, other.bankBottom, t)!,
    trees: Color.lerp(trees, other.trees, t)!,
    treesBottom: Color.lerp(treesBottom, other.treesBottom, t)!,
    light: Color.lerp(light, other.light, t)!,
  );
}

/// Day and night colors sampled from the reference, with matching twilight palettes.
class MountainLakeTheme extends ThemeExtension<MountainLakeTheme> {
  const MountainLakeTheme({
    this.night = const MountainLakePalette(
      skyTop: Color(0xff352969),
      horizon: Color(0xffa0d6f0),
      farMountain: Color(0xff4c8eb0),
      farMountainBottom: Color(0xff62a6b9),
      middleMountain: Color(0xff3d5790),
      middleMountainBottom: Color(0xff446898),
      nearMountain: Color(0xff363c7a),
      nearMountainBottom: Color(0xff49568b),
      water: Color(0xff8ec3e2),
      waterBottom: Color(0xff6e9cc7),
      bank: Color(0xff242951),
      bankBottom: Color(0xff282d55),
      trees: Color(0xff1c1c40),
      treesBottom: Color(0xff353460),
      light: Color(0xffdcf9f4),
    ),
    this.dawn = const MountainLakePalette(
      skyTop: Color(0xfff4729b),
      horizon: Color(0xfffce6db),
      farMountain: Color(0xffc95e8c),
      farMountainBottom: Color(0xffea849c),
      middleMountain: Color(0xffb54d7e),
      middleMountainBottom: Color(0xffdb6c97),
      nearMountain: Color(0xffb44e7e),
      nearMountainBottom: Color(0xffc4588a),
      water: Color(0xfff4bde4),
      waterBottom: Color(0xffd698cc),
      bank: Color(0xff652e55),
      bankBottom: Color(0xff692f57),
      trees: Color(0xff431a3c),
      treesBottom: Color(0xff622f56),
      light: Color(0xfffcf7f1),
    ),
    this.day = const MountainLakePalette(
      skyTop: Color(0xfff66294),
      horizon: Color(0xfffce6db),
      farMountain: Color(0xffc95e8c),
      farMountainBottom: Color(0xffea849c),
      middleMountain: Color(0xffdb6c97),
      middleMountainBottom: Color(0xffde6e9c),
      nearMountain: Color(0xffb44e7e),
      nearMountainBottom: Color(0xffcc5d90),
      water: Color(0xfff4bde4),
      waterBottom: Color(0xffd698cc),
      bank: Color(0xff652e55),
      bankBottom: Color(0xff692f57),
      trees: Color(0xff431a3c),
      treesBottom: Color(0xff622f56),
      light: Color(0xfffcf7f1),
    ),
    this.dusk = const MountainLakePalette(
      skyTop: Color(0xfff66294),
      horizon: Color(0xfffee4d3),
      farMountain: Color(0xffc95e8c),
      farMountainBottom: Color(0xffea849c),
      middleMountain: Color(0xffdb6c97),
      middleMountainBottom: Color(0xffde6e9c),
      nearMountain: Color(0xffb44e7e),
      nearMountainBottom: Color(0xffcc5d90),
      water: Color(0xfff4bde4),
      waterBottom: Color(0xffd698cc),
      bank: Color(0xff652e55),
      bankBottom: Color(0xff692f57),
      trees: Color(0xff431a3c),
      treesBottom: Color(0xff622f56),
      light: Color(0xfffcf7f1),
    ),
  });

  final MountainLakePalette night;
  final MountainLakePalette dawn;
  final MountainLakePalette day;
  final MountainLakePalette dusk;

  /// Uses local clock hours, without location access or astronomical services.
  MountainLakePalette paletteAt(double percentOfDay) {
    final hour = (percentOfDay % 1) * 24;
    final stops = [
      (0.0, night),
      (5.0, night),
      (6.5, dawn),
      (9.0, day),
      (16.0, day),
      (18.0, dusk),
      (20.0, night),
      (24.0, night),
    ];
    for (var i = 1; i < stops.length; i++) {
      if (hour <= stops[i].$1) {
        final previous = stops[i - 1];
        final next = stops[i];
        final progress = (hour - previous.$1) / (next.$1 - previous.$1);
        return previous.$2.lerp(next.$2, Curves.easeInOut.transform(progress));
      }
    }
    return night;
  }

  @override
  MountainLakeTheme copyWith({MountainLakePalette? night, MountainLakePalette? dawn, MountainLakePalette? day, MountainLakePalette? dusk}) =>
      MountainLakeTheme(night: night ?? this.night, dawn: dawn ?? this.dawn, day: day ?? this.day, dusk: dusk ?? this.dusk);

  @override
  MountainLakeTheme lerp(covariant MountainLakeTheme? other, double t) {
    if (other == null) return this;
    return MountainLakeTheme(night: night.lerp(other.night, t), dawn: dawn.lerp(other.dawn, t), day: day.lerp(other.day, t), dusk: dusk.lerp(other.dusk, t));
  }
}
