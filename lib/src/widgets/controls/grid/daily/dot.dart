import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data_value.dart';
import '../../../../util/media_query_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../series/data/view/series_data_tooltip_content.dart';
import '../../tooltip/lazy_tooltip.dart';
import 'day/day_item.dart';

class Dot<T extends SeriesDataValue> extends StatelessWidget {
  const Dot(
      {super.key,
      required this.dotColor1,
      this.dotColor2,
      this.dotText,
      this.isStartMarker = false,
      required this.seriesValues,
      this.showCount = false,
      this.tooltipValueBuilder});

  final Color dotColor1;
  final Color? dotColor2;
  final String? dotText;
  final bool isStartMarker;
  final bool showCount;
  final List<T> seriesValues;
  final Widget Function(T dataValue)? tooltipValueBuilder;

  static int get dotHeight => ThemeUtils.iconSizeScaled.ceil();

  static TextStyle _countTextStyle = const TextStyle(inherit: true);
  static TextStyle _dotTextStyle = const TextStyle(inherit: true);

  static void updateDotStyles(BuildContext context) {
    final themeData = Theme.of(context);
    final baseTextStyle = themeData.textTheme.bodyMedium ?? const TextStyle(inherit: true);
    _countTextStyle = baseTextStyle.copyWith(fontSize: 5);
    _dotTextStyle = baseTextStyle.copyWith(fontSize: 9);
  }

  @override
  Widget build(BuildContext context) {
    Widget? dotTextChild = dotText != null ? Text(dotText!, textAlign: TextAlign.right, style: _dotTextStyle) : null;
    double scale = MediaQueryUtils.textScaleFactor;

    Text? countText;
    int count = seriesValues.length;
    if (showCount && count > 1) {
      String cTxt = '$count';
      if (count < 100) {
        cTxt = '$count⠀'; // Braille Pattern Blank https://www.compart.com/en/unicode/U+2800
      } else if (count >= 1000) {
        cTxt = '+++';
      }
      countText = Text(
        cTxt,
        textAlign: TextAlign.center,
        style: _countTextStyle,
      );
    }

    var dotBoxDecoration = BoxDecoration(
      color: dotColor2 == null ? dotColor1 : null,
      gradient: dotColor2 != null
          ? LinearGradient(colors: [dotColor1, dotColor2!], begin: const AlignmentDirectional(0, -1), end: const AlignmentDirectional(0, 1))
          : null,
      borderRadius: BorderRadius.circular(2),
    );

    BoxDecoration? startMarkerBoxDecoration;
    if (isStartMarker) {
      var borderColor = _countTextStyle.color ?? Colors.grey;
      startMarkerBoxDecoration = BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5), left: BorderSide(color: borderColor, width: 0.5)),
      );
    }

    var dotRender = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 7 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 10 * scale,
              width: 10 * scale,
              decoration: dotBoxDecoration,
              child: dotTextChild,
            ),
          ],
        ),
        Container(
          height: 7 * scale,
          decoration: startMarkerBoxDecoration,
          child: countText,
        ),
      ],
    );

    if (count > 0 && tooltipValueBuilder != null) {
      return LazyTooltip(child: dotRender, tooltipBuilder: (_) => SeriesDataTooltipContent.buildSeriesValueTooltipWidget(seriesValues, tooltipValueBuilder!));
    }
    return dotRender;
  }

  static Dot noValueDot(DayItem<SeriesDataValue> dayItem, bool monthly) {
    return Dot(
      dotColor1: Colors.grey.withAlpha(64),
      isStartMarker: monthly ? false : dayItem.dateTimeDayStart.day == 1,
      seriesValues: [],
    );
  }
}
