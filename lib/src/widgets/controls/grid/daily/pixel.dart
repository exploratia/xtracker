import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data_value.dart';
import '../../../../util/chart/chart_utils.dart';
import '../../../../util/color_utils.dart';
import '../../../../util/math_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../series/data/view/series_data_tooltip_content.dart';
import '../../tooltip/lazy_tooltip.dart';

class Pixel<T extends SeriesDataValue> extends StatelessWidget {
  /// - [tooltipValueBuilder] called for every data value
  const Pixel({
    super.key,
    required this.colors,
    this.verticalGradient = false,
    this.pixelText,
    this.seriesValues,
    this.isStartMarker = false,
    this.backgroundColor,
    this.tooltipValueBuilder,
  });

  final List<Color> colors;
  final bool verticalGradient;
  final String? pixelText;
  final List<T>? seriesValues;
  final Widget? Function(T dataValue)? tooltipValueBuilder;
  final bool isStartMarker;
  final Color? backgroundColor;

  static int get pixelHeight => ThemeUtils.iconSizeScaled.ceil();

  static TextStyle _darkTextStyle = const TextStyle(inherit: true);
  static TextStyle _lightTextStyle = const TextStyle(inherit: true);
  static Color _themeTextColor = Colors.grey;
  static Color _borderColor = Colors.grey;

  static void updatePixelStyles(BuildContext context) {
    final themeData = Theme.of(context);
    _borderColor = themeData.scaffoldBackgroundColor;
    final baseTextStyle = themeData.textTheme.bodyMedium ?? const TextStyle(inherit: true);
    _themeTextColor = baseTextStyle.color ?? Colors.grey;
    _darkTextStyle = baseTextStyle.copyWith(
      color: Colors.white,
      fontSize: 10,
    );
    _lightTextStyle = baseTextStyle.copyWith(
      color: Colors.black,
      fontSize: 10,
    );
  }

  static Color pixelColor(Color baseColor, num value, num minVal, num maxVal, {bool invertHueDirection = false, double hueFactor = 30}) {
    var t = MathUtils.invLerp(minVal, maxVal, value);
    return ColorUtils.hue(baseColor, t * hueFactor * (invertHueDirection ? 1 : -1));
  }

  @override
  Widget build(BuildContext context) {
    Widget? pixelTextChild = pixelText != null
        ? Center(
            child: Text(
              pixelText!.length > 2 ? "++" : pixelText!,
              style: ColorUtils.isContrastingColorDark(colors.first) ? _lightTextStyle : _darkTextStyle,
            ),
          )
        : null;

    Color bottomLeftBorderColor = _borderColor;
    if (isStartMarker) {
      bottomLeftBorderColor = _themeTextColor; // black | white
    }
    Color topRightBorderColor = _borderColor;
    // if (backgroundColor != null) {
    //   topRightBorderColor = backgroundColor!; // to mark weekends
    // }

    LinearGradient? gradient;
    if (colors.length > 1) {
      if (verticalGradient) {
        gradient = ChartUtils.createBottomToTopGradient(colors);
      } else {
        gradient = ChartUtils.createLeftToRightGradient(colors);
      }
    }
    var pixelBoxDecoration = BoxDecoration(
      color: colors.length == 1 ? colors.first : null,
      gradient: gradient,
      borderRadius: isStartMarker
          ? const BorderRadius.only(topRight: Radius.circular(ThemeUtils.borderRadiusSmall))
          : const BorderRadius.all(Radius.circular(ThemeUtils.borderRadiusSmall)),
    );
    var pixelRender = Container(
      height: (pixelHeight - 2).toDouble(),
      decoration: pixelBoxDecoration,
      child: pixelTextChild,
    );

    Color? containerBackground;
    if (backgroundColor != null) {
      containerBackground = backgroundColor!.withAlpha(32);
    } else {
      containerBackground = Colors.grey.withAlpha(8);
    }
    var containerDecoration = BoxDecoration(
      color: containerBackground,
      // borderRadius: BorderRadius.circular(4), // not possible - A borderRadius can only be given on borders with uniform colors.
      border: Border(
        bottom: BorderSide(color: bottomLeftBorderColor, width: 1),
        left: BorderSide(color: bottomLeftBorderColor, width: 1),
        top: BorderSide(color: topRightBorderColor, width: 1),
        right: BorderSide(color: topRightBorderColor, width: 1),
      ),
    );

    var container = Container(
      height: pixelHeight.toDouble(),
      decoration: containerDecoration,
      child: pixelRender,
    );

    if (seriesValues != null && seriesValues!.isNotEmpty && tooltipValueBuilder != null) {
      return LazyTooltip(child: container, tooltipBuilder: (_) => SeriesDataTooltipContent.buildSeriesValueTooltipWidget(seriesValues!, tooltipValueBuilder));
    }
    return container;
  }
}
