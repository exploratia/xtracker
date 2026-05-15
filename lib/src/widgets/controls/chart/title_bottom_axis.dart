import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';

class TitleBottomAxis extends StatelessWidget {
  const TitleBottomAxis({super.key, required this.alignment, required this.value, this.dateFormatter, required this.height, required this.maxWidth});

  final Alignment alignment;
  final num value;
  final String Function(DateTime dateTime)? dateFormatter;
  final double height;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    var child = Text(dateFormatter == null ? value.toString() : dateFormatter!(DateTime.fromMillisecondsSinceEpoch(value.truncate())));
    return SizedBox(
      width: 0,
      height: height,
      child: OverflowBox(
        alignment: alignment,
        maxWidth: maxWidth,
        maxHeight: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.paddingSmall, vertical: ThemeUtils.paddingSmall / 2),
          child: child,
        ),
      ),
    );
  }
}
