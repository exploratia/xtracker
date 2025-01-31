import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_utils.dart';

class ThemeUtils {
  static final MaterialColor primary =
      ColorUtils.customMaterialColor(const Color(0xffde0b30));
  static final Color onPrimary = Colors.white;
  static final MaterialColor
      secondary = // e.g. when pulling down | toggle switch
      ColorUtils.customMaterialColor(const Color(0xff911d31));
  static final MaterialColor tertiary =
      ColorUtils.customMaterialColor(const Color(0xffbfff00));
  static final List<Color> gradientColors = [
    const Color(0xff4c1a57),
    const Color(0xff00a8aa),
    const Color(0xffa6e300)
  ];
  static final Color onGradientColor = Colors.white;
  static final screenPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 16); // .all(16);
  static final cardBorderRadius = BorderRadius.all(Radius.circular(20));
  static final cardPadding = EdgeInsets.all(20);
  static final btnShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));

  static ThemeData? _light;
  static ThemeData? _dark;

  static ThemeData buildThemeData(BuildContext context, bool dark) {
    // already stored? Return instantly...
    // if (dark && _dark != null) return _dark!;
    // if (!dark && _light != null) return _light!;

    final brightness = dark ? Brightness.dark : Brightness.light;
    final backgroundColor =
        dark ? const Color(0xff06041f) : const Color.fromRGBO(240, 240, 240, 1);
    final cardBackgroundColor =
        dark ? Color(0xff1f1d35) : const Color.fromRGBO(235, 235, 235, 1.0);
    final chipBackgroundColor =
        dark ? Color(0xff38364c) : const Color.fromRGBO(209, 209, 209, 1.0);
    final canvasColor =
        dark ? Color(0xff38364c) : const Color.fromRGBO(240, 240, 240, 1);

    final drawerBackgroundColor =
        dark ? const Color.fromRGBO(7, 7, 7, 1) : Colors.white;

    var themeData = ThemeData(
      useMaterial3: false,
      brightness: brightness,
      // canvas e.g. DropdownButton-Menu in settings
      canvasColor: canvasColor,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: dark ? Colors.white : Colors.black,
        actionsIconTheme:
            IconThemeData(color: dark ? Colors.white : Colors.black),
        systemOverlayStyle:
            dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      tabBarTheme:
          TabBarThemeData(indicatorColor: dark ? Colors.white : Colors.black),
      colorScheme:
          ColorScheme.fromSeed(seedColor: primary, brightness: brightness)
              .copyWith(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onPrimary,
        tertiary: tertiary,
      ),
      textTheme: const TextTheme(
          // titleLarge: TextStyle(color: dynamicThemeData.getPrimaryColor(dark)),
          // titleMedium: TextStyle(fontWeight: FontWeight.bold),
          // titleSmall: TextStyle(color: dynamicThemeData.getPrimaryColor(dark)),
          ),
      drawerTheme: Theme.of(context)
          .drawerTheme
          .copyWith(backgroundColor: drawerBackgroundColor),
      // dividerColor: dividerColor, // Trenner bei MenuItems-Gruppierung
      scaffoldBackgroundColor: backgroundColor /* otherwise white|black */,
      scrollbarTheme: Theme.of(context).scrollbarTheme.copyWith(
            thumbColor: WidgetStatePropertyAll(primary),
            radius: Radius.zero,
            interactive: true,
            // thickness: const MaterialStatePropertyAll(10),
            // thumbVisibility: const MaterialStatePropertyAll(true),
            // trackVisibility: const MaterialStatePropertyAll(true),
            // trackColor: const MaterialStatePropertyAll(Colors.blueAccent),
            // trackBorderColor: const MaterialStatePropertyAll(Colors.purpleAccent),
          ),

      // Card (e.g. in Settings)
      cardTheme: Theme.of(context).cardTheme.copyWith(
            color: cardBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: ThemeUtils.cardBorderRadius,
            ),
          ),
      chipTheme: ChipThemeData(backgroundColor: chipBackgroundColor),
      dialogTheme: DialogTheme(
        backgroundColor: chipBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: ThemeUtils.cardBorderRadius,
        ),
      ),
      dividerTheme: DividerThemeData(color: secondary, thickness: 1, space: 10),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        shape: btnShape,
      )),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        shape: btnShape,
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
        shape: btnShape,
      )),
    );

    if (dark) {
      _dark = themeData;
    } else {
      _light = themeData;
    }

    return themeData;
  }
}
