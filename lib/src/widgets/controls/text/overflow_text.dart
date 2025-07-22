import 'package:flutter/material.dart';

class OverflowText extends StatelessWidget {
  /// Widget for TextOverflow - ellipses or fade
  const OverflowText(
    this.text, {
    super.key,
    this.maxLines = 1,
    this.textOverflow = TextOverflow.ellipsis,
    this.style,
    this.textAlign,
    this.expanded = true,
  });

  final String text;
  final TextOverflow? textOverflow;
  final TextStyle? style;
  final int maxLines;
  final TextAlign? textAlign;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    var textWidget = Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      overflow: textOverflow,
      maxLines: maxLines,
      softWrap: false,
      style: style,
    );

    if (!expanded) return textWidget;

    return Expanded(child: textWidget);
  }
}
