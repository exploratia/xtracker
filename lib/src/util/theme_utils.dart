import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_utils.dart';
import 'navigation/fade_transition_builder.dart';

class ThemeUtils {
  static final MaterialColor primary = ColorUtils.customMaterialColor(const Color(0xffde0b30));
  static const Color onPrimary = Colors.white;

  // e.g. when pulling down | toggle switch:
  static final MaterialColor secondary = ColorUtils.customMaterialColor(const Color(0xff911d31));
  static final MaterialColor tertiary = ColorUtils.customMaterialColor(const Color(0xffbfff00));

  static const screenPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 16); // .all(16);
  static const cardBorderRadius = BorderRadius.all(Radius.circular(20));
  static const cardPadding = EdgeInsets.all(20);
  static final btnShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
  static const double seriesDataViewTopPadding = 48;
  static const double seriesDataInputDlgMaxWidth = 300;

  static ThemeData? _light;
  static ThemeData? _dark;

  static ThemeData buildThemeData(BuildContext context, bool dark) {
    // already stored? Return instantly...
    if (dark && _dark != null) return _dark!;
    if (!dark && _light != null) return _light!;

    final brightness = dark ? Brightness.dark : Brightness.light;
    final backgroundColor = dark ? const Color(0xff06041f) : const Color.fromRGBO(255, 255, 255, 1);
    final cardBackgroundColor = dark ? const Color(0xff1f1d35) : const Color.fromRGBO(235, 235, 235, 1.0);
    final chipBackgroundColor = dark ? const Color(0xff38364c) : const Color.fromRGBO(209, 209, 209, 1.0);
    final canvasColor = dark ? const Color(0xff38364c) : const Color.fromRGBO(240, 240, 240, 1);

    final shadowColor = dark ? backgroundColor : Colors.black45;
    var themeData = ThemeData(
      useMaterial3: false,
      brightness: brightness,
      // canvas e.g. DropdownButton-Menu in settings
      canvasColor: canvasColor,
      shadowColor: shadowColor,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: brightness).copyWith(
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
      appBarTheme: AppBarTheme(
        elevation: 8,
        backgroundColor: secondary,
        // backgroundColor,
        foregroundColor: onPrimary,
        // dark ? Colors.white : Colors.black,
        actionsIconTheme: const IconThemeData(
          color: onPrimary, // dark ? Colors.white : Colors.black,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        // dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        shadowColor: shadowColor,
      ),
      tabBarTheme: TabBarThemeData(indicatorColor: dark ? Colors.white : Colors.black),
      drawerTheme: DrawerThemeData(
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(5), // 2 if scrollable
          ),
        ),
      ),
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
      bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: backgroundColor, selectedItemColor: primary),
      snackBarTheme: SnackBarThemeData(backgroundColor: cardBackgroundColor, contentTextStyle: TextStyle(color: dark ? Colors.white : Colors.black)),
      // Card (e.g. in Settings)
      cardTheme: Theme.of(context).cardTheme.copyWith(
            color: cardBackgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: ThemeUtils.cardBorderRadius,
            ),
          ),
      chipTheme: ChipThemeData(backgroundColor: chipBackgroundColor),
      dialogTheme: DialogThemeData(
        // for fullscreen background has to be set manually
        backgroundColor: chipBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: ThemeUtils.cardBorderRadius,
        ),
      ),
      datePickerTheme: DatePickerThemeData(headerBackgroundColor: cardBackgroundColor),
      timePickerTheme: TimePickerThemeData(backgroundColor: chipBackgroundColor),
      dividerTheme: DividerThemeData(color: secondary, thickness: 1, space: 10),
      navigationRailTheme: NavigationRailThemeData(backgroundColor: backgroundColor),
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeTransitionsBuilder(),
          // TargetPlatform.iOS: CustomPageTransition(),
        },
      ),
    );

    if (dark) {
      _dark = themeData;
    } else {
      _light = themeData;
    }

    return themeData;
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
