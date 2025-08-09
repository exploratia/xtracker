import 'package:flutter/material.dart';

class Dot extends StatelessWidget {
  const Dot({super.key, required this.dotColor1, this.dotColor2, this.count, this.dotText, this.isStartMarker = false});

  final int? count;
  final Color dotColor1;
  final Color? dotColor2;
  final String? dotText;
  final bool isStartMarker;

  static const int dotHeight = 24;

  static TextStyle _countTextStyle = const TextStyle(inherit: true);
  static TextStyle _dotTextStyle = const TextStyle(inherit: true);

  static void updateDotTextStyles(BuildContext context) {
    final themeData = Theme.of(context);
    final baseTextStyle = themeData.textTheme.bodyMedium ?? const TextStyle(inherit: true);
    _countTextStyle = baseTextStyle.copyWith(fontSize: 5);
    _dotTextStyle = baseTextStyle.copyWith(fontSize: 9);
  }

  @override
  Widget build(BuildContext context) {
    Widget? dotTextChild = dotText != null ? Text(dotText!, textAlign: TextAlign.right, style: _dotTextStyle) : null;

    Text? countText;
    if (count != null) {
      String cTxt = '$count';
      if (count! < 100) {
        cTxt = '$count⠀'; // Braille Pattern Blank https://www.compart.com/en/unicode/U+2800
      } else if (count! >= 1000) {
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

    return Column(
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
  }
}
