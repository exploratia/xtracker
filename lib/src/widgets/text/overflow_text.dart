import 'package:flutter/material.dart';

class OverflowText extends StatelessWidget {
  /// Widget for TextOverflow - ellipses or fade
  const OverflowText(this.text, {super.key, this.textOverflow = TextOverflow.ellipsis, this.style});

  final String text;
  final TextOverflow? textOverflow;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SizedBox(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: false,
          style: style,
        ),
      ),
    );
  }
}
