import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data_value.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/pair.dart';
import '../../../../util/tooltip_utils.dart';

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

  static const int dotHeight = 24;

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
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: dotBoxDecoration,
              child: dotTextChild,
            ),
          ],
        ),
        Container(
          height: 7,
          decoration: startMarkerBoxDecoration,
          child: countText,
        ),
      ],
    );

    if (count > 0 && tooltipValueBuilder != null) {
      TextSpan richMessage = buildSeriesValueTooltip(seriesValues, tooltipValueBuilder!);

      return Tooltip(
        richMessage: richMessage,
        textStyle: TooltipUtils.tooltipMonospaceStyle,
        child: dotRender,
      );
    }
    return dotRender;
  }

  static TextSpan buildSeriesValueTooltip<T extends SeriesDataValue>(List<T> seriesValues, Widget Function(T dataValue) tooltipValueBuilder) {
    List<InlineSpan>? richMessageChildren = [
      TextSpan(
        children: [
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.calendar_today_outlined, size: 12),
          ),
          const WidgetSpan(child: SizedBox(width: 5)),
          TextSpan(text: DateTimeUtils.formateDate(seriesValues.first.dateTime), style: TooltipUtils.tooltipMonospaceStyle),
        ],
      )
    ];

    // bring all times to same length for showing a nice table like tooltip
    List<Pair<String, Widget>> timeValuePairs = [];

    for (var value in seriesValues) {
      timeValuePairs.add(Pair(DateTimeUtils.formateTime(value.dateTime), tooltipValueBuilder(value)));
    }

    final maxLength = timeValuePairs.map((p) => p.k.length).reduce((a, b) => a > b ? a : b);
    int c = 0;
    for (var timeValuePair in timeValuePairs) {
      if (c >= 9) {
        richMessageChildren.add(TextSpan(text: '\n- ...', style: TooltipUtils.tooltipMonospaceStyle));
        break;
      }
      richMessageChildren.add(tooltipValueLine(timeValuePair.k.padLeft(maxLength), timeValuePair.v));
      c++;
    }

    final richMessage = TextSpan(children: richMessageChildren);
    return richMessage;
  }

  static TextSpan tooltipValueLine(String time, Widget value) {
    return TextSpan(
      children: [
        TextSpan(text: "\n", style: TooltipUtils.tooltipMonospaceStyle),
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Icon(Icons.access_time_outlined, size: 12),
        ),
        const WidgetSpan(child: SizedBox(width: 5)),
        TextSpan(text: time, style: TooltipUtils.tooltipMonospaceStyle),
        const WidgetSpan(child: SizedBox(width: 15)),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: value,
        ),
      ],
    );
  }
}
