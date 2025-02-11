import 'package:flutter/material.dart';

class OverflowText extends StatelessWidget {
  /// Widget for TextOverflow - ellipses or fade
  const OverflowText(
    this.text, {
    super.key,
    this.maxLines = 1,
    this.textOverflow = TextOverflow.ellipsis,
    this.style,
  });

  final String text;
  final TextOverflow? textOverflow;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        overflow: textOverflow,
        maxLines: maxLines,
        softWrap: false,
        style: style,
      ),
    );
  }
}
