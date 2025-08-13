import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data_value.dart';
import '../../../../util/color_utils.dart';
import '../../../../util/math_utils.dart';
import '../../../../util/tooltip_utils.dart';
import 'dot.dart';

class Pixel<T extends SeriesDataValue> extends StatelessWidget {
  const Pixel({super.key, required this.colors, this.pixelText, this.seriesValues, this.isStartMarker = false, this.backgroundColor, this.tooltipValueBuilder});

  final List<Color> colors;
  final String? pixelText;
  final List<T>? seriesValues;
  final Widget Function(T dataValue)? tooltipValueBuilder;
  final bool isStartMarker;
  final Color? backgroundColor;

  static const int pixelHeight = 24;

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

    Color? singleColorBackground;
    if (colors.isEmpty) {
      if (backgroundColor != null) {
        singleColorBackground = backgroundColor!.withAlpha(32);
      } else {
        singleColorBackground = Colors.grey.withAlpha(8);
      }
    } else if (colors.length == 1) {
      singleColorBackground = colors.first;
    }

    var pixelBoxDecoration = BoxDecoration(
      color: singleColorBackground,
      gradient: colors.length > 1 ? LinearGradient(colors: colors) : null,
      border: Border(
        bottom: BorderSide(color: bottomLeftBorderColor, width: 1),
        left: BorderSide(color: bottomLeftBorderColor, width: 1),
        top: BorderSide(color: topRightBorderColor, width: 1),
        right: BorderSide(color: topRightBorderColor, width: 1),
      ),
    );

    var pixelRender = Container(
      height: pixelHeight.toDouble(),
      decoration: pixelBoxDecoration,
      child: pixelTextChild,
    );

    if (seriesValues != null && seriesValues!.isNotEmpty && tooltipValueBuilder != null) {
      TextSpan richMessage = Dot.buildSeriesValueTooltip(seriesValues!, tooltipValueBuilder!);

      return Tooltip(
        richMessage: richMessage,
        textStyle: TooltipUtils.tooltipMonospaceStyle,
        child: pixelRender,
      );
    }
    return pixelRender;
  }
}
