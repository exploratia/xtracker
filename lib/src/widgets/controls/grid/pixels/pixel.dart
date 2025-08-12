import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data_value.dart';
import '../../../../util/color_utils.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/math_utils.dart';
import '../../../../util/pair.dart';
import '../../../../util/tooltip_utils.dart';

class Pixel extends StatelessWidget {
  const Pixel({super.key, required this.colors, this.pixelText, this.seriesValues});

  final List<Color> colors;
  final String? pixelText;
  final List<SeriesDataValue>? seriesValues;

  static const int pixelHeight = 24;

  static TextStyle _darkTextStyle = const TextStyle(inherit: true);
  static TextStyle _lightTextStyle = const TextStyle(inherit: true);
  static Color _borderColor = Colors.grey;

  static void updatePixelTextStyles(BuildContext context) {
    final themeData = Theme.of(context);
    _borderColor = themeData.scaffoldBackgroundColor;
    final baseTextStyle = themeData.textTheme.bodyMedium ?? const TextStyle(inherit: true);
    _darkTextStyle = baseTextStyle.copyWith(
      color: Colors.white,
      // fontSize: 5,
    );
    _lightTextStyle = baseTextStyle.copyWith(
      color: Colors.black,
      // fontSize: 9,
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

    var pixelBoxDecoration = BoxDecoration(
      color: colors.length == 1 ? colors.first : null,
      gradient: colors.length > 1 ? LinearGradient(colors: colors) : null,
      border: Border(bottom: BorderSide(color: _borderColor, width: 1), left: BorderSide(color: _borderColor, width: 1)),
    );

    var pixelRender = Container(
      height: pixelHeight.toDouble(),
      decoration: pixelBoxDecoration,
      child: pixelTextChild,
    );

    if (seriesValues != null && seriesValues!.isNotEmpty) {
      var tooltipText = '▹ ${DateTimeUtils.formateDate(seriesValues!.first.dateTime)}';

      // bring all times to same length for showing a nice table like tooltip
      List<Pair<String, String>> timeValuePairs = [];

      for (var value in seriesValues!) {
        timeValuePairs.add(Pair(DateTimeUtils.formateTime(value.dateTime), value.toTooltip()));
      }

      final maxLength = timeValuePairs.map((p) => p.k.length).reduce((a, b) => a > b ? a : b);
      for (var timeValuePair in timeValuePairs) {
        tooltipText += '\n- ${timeValuePair.k.padLeft(maxLength)}   ${timeValuePair.v}';
      }

      return Tooltip(
        message: tooltipText,
        textStyle: TooltipUtils.tooltipMonospaceStyle,
        child: pixelRender,
      );
    }
    return pixelRender;
  }
}
