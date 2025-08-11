import 'package:flutter/material.dart';

class ColorUtils {
  // https://stackoverflow.com/questions/58360989/programmatically-lighten-or-darken-a-hex-color-in-dart

  /// Darken a color by [percent] amount (100 = black)
  static Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB((c.a * 255).toInt(), ((c.r * 255).toInt() * f).round(), ((c.g * 255).toInt() * f).round(), ((c.b * 255).toInt() * f).round());
  }

  /// Lighten a color by [percent] amount (100 = white)
  static Color lighten(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB((c.a * 255).toInt(), (c.r * 255).toInt() + ((255 - (c.r * 255).toInt()) * p).round(),
        (c.g * 255).toInt() + ((255 - (c.g * 255).toInt()) * p).round(), (c.b * 255).toInt() + ((255 - (c.b * 255).toInt()) * p).round());
  }

  /// - add [[0, 360]]
  static Color hue(Color c, [double add = 10]) {
    var hsl = HSLColor.fromColor(c);
    return hsl.withHue((hsl.hue + add) % 360).toColor();
  }

  static Color fromHex(String hex) {
    String hexColor = hex.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.tryParse(hexColor, radix: 16) ?? 0);
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  static String toHex(Color c, {bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${(c.a * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(c.r * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(c.g * 255).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(c.b * 255).toInt().toRadixString(16).padLeft(2, '0')}';

  /// usage: e.g. <pre>MaterialColor mColor = customMaterialColor(const Color(0xffbab0d4));</pre>
  static MaterialColor customMaterialColor(Color mainColor) {
    Map<int, Color> colors = {
      50: ColorUtils.lighten(mainColor, 88),
      100: ColorUtils.lighten(mainColor, 70),
      200: ColorUtils.lighten(mainColor, 51),
      300: ColorUtils.lighten(mainColor, 31),
      400: ColorUtils.lighten(mainColor, 15),
      500: mainColor,
      600: ColorUtils.darken(mainColor, 8),
      700: ColorUtils.darken(mainColor, 20),
      800: ColorUtils.darken(mainColor, 33),
      900: ColorUtils.darken(mainColor, 52),
    };
    return MaterialColor(_toInt(mainColor), colors);
  }

  static int _toInt(Color c) {
    final alpha = (c.a * 255).toInt();
    final red = (c.r * 255).toInt();
    final green = (c.g * 255).toInt();
    final blue = (c.b * 255).toInt();
    // Combine the components into a single int using bit shifting
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }

  static Color getContrastingTextColor(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
