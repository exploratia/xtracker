import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';

class TitleBottomAxis extends StatelessWidget {
  const TitleBottomAxis({super.key, required this.alignment, required this.value, required this.dateFormatter, required this.height, required this.maxWidth});

  final Alignment alignment;
  final double value;
  final String Function(DateTime dateTime) dateFormatter;
  final double height;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0,
      height: height,
      child: OverflowBox(
        alignment: alignment,
        maxWidth: maxWidth,
        maxHeight: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.paddingSmall, vertical: ThemeUtils.paddingSmall / 2),
          child: Text(dateFormatter(DateTime.fromMillisecondsSinceEpoch(value.truncate()))),
        ),
      ),
    );
  }
}
