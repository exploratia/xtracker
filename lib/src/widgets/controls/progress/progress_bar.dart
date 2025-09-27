import 'package:flutter/material.dart';

import '../../../util/chart/chart_utils.dart';
import '../../../util/color_utils.dart';
import '../../../util/theme_utils.dart';
import '../card/glowing_border_container.dart';

class ProgressBar extends StatelessWidget {
  /// - [value] percentage value between 0 and 1
  const ProgressBar({super.key, required this.value, this.padding, this.color});

  final double value;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    Color col = color ?? ThemeUtils.secondary;
    Color gradientColor = ColorUtils.gradientColor(col);
    Widget progress = Container(
      height: ThemeUtils.borderRadiusSmall * 2,
      clipBehavior: Clip.antiAlias,
      decoration: GlowingBorderContainer.createGlowingBoxDecoration(
        col,
        backgroundColor: themeData.cardTheme.color,
        borderRadius: ThemeUtils.borderRadiusSmall,
        blurRadius: ThemeUtils.borderRadiusSmall,
        borderWidth: 1,
      ),
      child: FractionallySizedBox(
        alignment: AlignmentGeometry.topLeft,
        widthFactor: value,
        heightFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            // color: color ?? ThemeUtils.secondary,
            gradient: ChartUtils.createLeftToRightGradient([col, gradientColor]),
            borderRadius: BorderRadius.circular(ThemeUtils.borderRadiusSmall),
          ),
        ),
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
