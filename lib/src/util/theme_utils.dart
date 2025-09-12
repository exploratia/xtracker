import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/controls/card/glowing_border_container.dart';
import 'color_utils.dart';
import 'media_query_utils.dart';
import 'navigation/fade_transition_builder.dart';

class ThemeUtils {
  static final MaterialColor primary = ColorUtils.customMaterialColor(const Color(0xffde0b30));
  static const Color onPrimary = Colors.white;

  // e.g. when pulling down | toggle switch:
  static final MaterialColor secondary = ColorUtils.customMaterialColor(const Color(0xff911d31));
  static final MaterialColor tertiary = ColorUtils.customMaterialColor(const Color(0xffbfff00));

  static const double screenPadding = 16;
  static const double cardPadding = 16;
  static const double defaultPadding = 8;
  static const double paddingSmall = 4;
  static const double horizontalSpacing = 8;
  static const double horizontalSpacingSmall = 4;
  static const double horizontalSpacingLarge = 16;
  static const double verticalSpacing = 12;
  static const double verticalSpacingSmall = 4;
  static const double verticalSpacingLarge = 24;
  static const double borderRadius = 8;
  static const double borderRadiusSmall = 4;
  static const double borderRadiusLarge = 16;
  static const double elevation = 4;
  static const double iconSize = 24;
  static const double fontSizeTitleL = 20;
  static const double fontSizeTitleM = 16;
  static const double fontSizeTitleS = 14;
  static const double fontSizeBodyL = 14;
  static const double fontSizeBodyM = 14;
  static const double fontSizeBodyS = 12;
  static const double fontSizeLabelL = 14;
  static const double fontSizeLabelM = 12;
  static const double fontSizeLabelS = 10;

  static double get iconSizeScaled => iconSize * MediaQueryUtils.textScaleFactor;

  static const int animationDuration = 300;
  static const int animationDurationShort = 150;

  static final borderRadiusCircular = BorderRadius.circular(borderRadius);
  static final borderRadiusCircularSmall = BorderRadius.circular(borderRadiusSmall);

  static const screenPaddingAll = EdgeInsets.all(screenPadding); // .all(screenPaddingValue);
  static final cardBorderRadius = BorderRadius.circular(20);
  static const cardPaddingAll = EdgeInsets.all(20);
  static final btnShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));
  static const double seriesDataInputDlgMaxWidth = 300;

  /// [seriesDataBottomFilterViewHeight] = 56 (e.g. Slider height 48 + padding/borders)
  static const double seriesDataBottomFilterViewHeight = 56;

  static ThemeData? _light;
  static ThemeData? _dark;

  static ThemeData buildThemeData(BuildContext context, bool dark) {
    // already stored? Return instantly...
    if (dark && _dark != null) return _dark!;
    if (!dark && _light != null) return _light!;

    final brightness = dark ? Brightness.dark : Brightness.light;
    final backgroundColor = dark ? const Color(0xff06041f) : const Color(0xfff0f0f0);
    final cardBackgroundColor = dark ? const Color(0xff1f1d35) : const Color(0xfffdfdfd);
    final chipBackgroundColor = dark ? const Color(0xff38364c) : const Color(0xffd1d1d1);
    final canvasColor = dark ? const Color(0xff38364c) : const Color.fromRGBO(240, 240, 240, 1);

    final shadowColor = dark ? backgroundColor : Colors.black45;
    final textColor = dark ? Colors.white : Colors.black;

    var themeData = ThemeData(
      useMaterial3: false,
      brightness: brightness,
      canvasColor: canvasColor /* canvas e.g. DropdownButton-Menu in settings */,
      scaffoldBackgroundColor: backgroundColor /* otherwise white|black */,
      shadowColor: shadowColor,
      focusColor: primary.withAlpha(64),
      // themes
      appBarTheme: AppBarTheme(
        elevation: elevation * 2,
        backgroundColor: secondary,
        foregroundColor: onPrimary,
        actionsIconTheme: const IconThemeData(
          color: onPrimary,
          size: iconSize,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        // dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        shadowColor: shadowColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dark ? cardBackgroundColor : chipBackgroundColor,
        elevation: 0,
        selectedItemColor: primary,
        unselectedItemColor: textColor,
      ),
      // Card (e.g. in Settings)
      cardTheme: CardThemeData(
        color: cardBackgroundColor,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: ThemeUtils.cardBorderRadius,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBackgroundColor,
        iconTheme: IconThemeData(
          size: iconSize,
          color: primary,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: brightness).copyWith(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onPrimary,
        tertiary: tertiary,
      ),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: cardBackgroundColor,
        headerForegroundColor: textColor,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: chipBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: ThemeUtils.cardBorderRadius,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: secondary,
        thickness: 1,
        space: verticalSpacing,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(5), // 2 if scrollable
          ),
        ),
      ),
      iconTheme: IconThemeData(
        size: iconSize,
        color: textColor,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: backgroundColor,
        unselectedLabelTextStyle: TextStyle(color: textColor),
        unselectedIconTheme: IconThemeData(color: textColor),
        useIndicator: false,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: secondary.withAlpha(128),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(primary),
        radius: Radius.zero,
        interactive: true,
        // thickness: const MaterialStatePropertyAll(10),
        // thumbVisibility: const MaterialStatePropertyAll(true),
        // trackVisibility: const MaterialStatePropertyAll(true),
        // trackColor: const MaterialStatePropertyAll(Colors.blueAccent),
        // trackBorderColor: const MaterialStatePropertyAll(Colors.purpleAccent),
      ),
      sliderTheme: SliderThemeData(
        valueIndicatorColor: cardBackgroundColor,
        valueIndicatorTextStyle: TextStyle(color: textColor),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? cardBackgroundColor : chipBackgroundColor,
        elevation: 8,
        contentTextStyle: TextStyle(color: textColor, fontSize: fontSizeBodyM),
      ),
      tabBarTheme: TabBarThemeData(indicatorColor: textColor),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: textColor, fontSize: fontSizeTitleL, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: textColor, fontSize: fontSizeTitleM, fontWeight: FontWeight.w400),
        titleSmall: TextStyle(color: textColor, fontSize: fontSizeTitleS, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textColor, fontSize: fontSizeBodyL, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(color: textColor, fontSize: fontSizeBodyM, fontWeight: FontWeight.w500),
        bodySmall: TextStyle(color: textColor, fontSize: fontSizeBodyS, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: textColor, fontSize: fontSizeLabelL, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: textColor, fontSize: fontSizeLabelM, fontWeight: FontWeight.w400),
        labelSmall: TextStyle(color: textColor, fontSize: fontSizeLabelS, fontWeight: FontWeight.w400),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: chipBackgroundColor,
      ),
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.all(defaultPadding),
        textStyle: TextStyle(
          color: textColor,
          fontSize: fontSizeBodyM,
        ),
        // decoration: GlowingBorderContainer.createGlowingBoxDecoration(secondary, secondary),
        decoration: GlowingBorderContainer.createGlowingBoxDecoration(secondary, dark ? backgroundColor : cardBackgroundColor),
        waitDuration: const Duration(milliseconds: 500),
        // showDuration: Duration(seconds: 2),
        preferBelow: false,
        constraints: const BoxConstraints(maxWidth: 300),
      ),
      // buttons
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: btnShape)),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: btnShape)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: btnShape)),
      // page transition
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
