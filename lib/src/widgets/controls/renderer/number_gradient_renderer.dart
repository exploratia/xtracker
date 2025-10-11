import 'package:flutter/material.dart';

import '../../../util/chart/chart_utils.dart';
import '../../../util/color_utils.dart';
import '../../../util/theme_utils.dart';

class NumberGradientRenderer extends StatelessWidget {
  const NumberGradientRenderer({
    super.key,
    this.baseColor,
    required this.numbers,
    this.height = 8,
    this.hueFactor = 15,
  });

  final Color? baseColor;
  final Iterable<num> numbers;
  final int height;
  final double hueFactor;

  @override
  Widget build(BuildContext context) {
    Color color = baseColor ?? ThemeUtils.secondary;
    return Container(
      height: 8,
      decoration: BoxDecoration(
        gradient: ChartUtils.createLeftToRightGradient(
          numbers
              .map((e) => e < 1 ? Colors.transparent : ColorUtils.hue(color, (e.clamp(1, 4) - 1) * hueFactor))
              .expand((c) => [c, c, Colors.transparent])
              .toList()
            ..insert(0, Colors.transparent),
        ),
      ),
    );
  }
}
