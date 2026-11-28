import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../../../model/series/tags/tag.dart';
import '../../../util/chart/chart_utils.dart';
import '../../../util/color_utils.dart';
import '../../../util/theme_utils.dart';
import '../text/overflow_text.dart';

class TagRenderer extends StatelessWidget {
  final Tag tag;
  final double maxContentWidth;
  final EdgeInsetsGeometry? margin;

  const TagRenderer({
    super.key,
    required this.tag,
    this.maxContentWidth = -1,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    Widget widget = Container(
      padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
      margin: margin,
      decoration: BoxDecoration(
        gradient: ChartUtils.createLeftToRightGradient(buildTagGradient(tag.color)),
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
      ),
      child: OverflowText(
        expanded: false,
        tag.name,
        style: themeData.textTheme.labelMedium?.copyWith(color: ColorUtils.getContrastingTextColor(tag.color)),
      ),
    );

    if (maxContentWidth >= 0) {
      widget = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max(maxContentWidth - 8, 20)),
        child: widget,
      );
    }

    return widget;
  }

  static List<Color>? buildTagGradient(Color color) {
    return [color, ColorUtils.gradientColor(color)];
  }
}
