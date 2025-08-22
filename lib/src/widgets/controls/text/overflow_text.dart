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
    this.flexible = false,
  });

  final String text;
  final TextOverflow? textOverflow;
  final TextStyle? style;
  final int maxLines;
  final TextAlign? textAlign;
  final bool expanded;
  final bool flexible;

  @override
  Widget build(BuildContext context) {
    Widget result = Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      overflow: textOverflow,
      maxLines: maxLines,
      softWrap: false,
      style: style,
    );

    if (expanded) result = Expanded(child: result);
    if (flexible) result = Flexible(child: result);

    return result;
  }
}
