import 'dart:math';

import 'package:flutter/material.dart';

import '../../../util/color_utils.dart';
import '../../../util/theme_utils.dart';
import '../card/glowing_border_container.dart';

class RangeBar extends StatelessWidget {
  /// - [value] percentage value between 0 and 1
  /// - [value2] percentage value between 0 and 1
  const RangeBar({super.key, required this.value, this.value2, this.padding, this.color});

  final double value;
  final double? value2;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    double from = min(value, value2 ?? value).clamp(0, 1);
    double to = max(value, value2 ?? value).clamp(0, 1);
    // only one value?
    if (to - from < 0.01) {
      from = (from - 0.01).clamp(0, 1);
      to = (to + 0.01).clamp(0, 1);
    }

    Color col = color ?? ThemeUtils.secondary;
    Color gradientColor = ColorUtils.gradientColor(col);
    Widget progress = SizedBox(
      height: ThemeUtils.borderRadiusSmall * 2,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (from > 0) Expanded(flex: (from * 100).toInt(), child: Container()),
          Expanded(
            flex: ((to - from) * 100).toInt(),
            child: Container(
              decoration: GlowingBorderContainer.createGlowingBoxDecoration(
                col,
                backgroundGradientColors: [col, gradientColor],
                borderRadius: ThemeUtils.borderRadiusSmall,
                borderWidth: 0,
                blurRadius: ThemeUtils.borderRadiusSmall,
              ),
            ),
          ),
          if (to < 1) Expanded(flex: ((1 - to) * 100).toInt(), child: Container()),
        ],
      ),
    );

    if (padding != null) {
      progress = Padding(
        padding: padding!,
        child: progress,
      );
    }

    return progress;
  }
}
