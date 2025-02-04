import 'package:flutter/material.dart';

class TextUtils {
  static Size determineTextSize(
      String text, BuildContext context, TextStyle? textStyle) {
    final Size size = (TextPainter(
            text: TextSpan(text: text, style: textStyle),
            maxLines: 1,
            textScaler: MediaQuery.of(context).textScaler,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    return size;
  }
}
