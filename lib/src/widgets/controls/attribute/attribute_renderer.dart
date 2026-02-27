import 'dart:math';

import 'package:flutter/material.dart';

import '../../../model/series/attributes/attribute.dart';
import '../../../util/chart/chart_utils.dart';
import '../../../util/color_utils.dart';
import '../../../util/theme_utils.dart';
import '../text/overflow_text.dart';

class AttributeRenderer extends StatelessWidget {
  final Attribute attribute;
  final double maxContentWidth;
  final EdgeInsetsGeometry? margin;

  const AttributeRenderer({
    super.key,
    required this.attribute,
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
        gradient: ChartUtils.createLeftToRightGradient(buildAttributeGradient(attribute.color)),
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
      ),
      child: OverflowText(
        expanded: false,
        attribute.name,
        style: themeData.textTheme.labelMedium?.copyWith(color: ColorUtils.getContrastingTextColor(attribute.color)),
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

  static List<Color>? buildAttributeGradient(Color color) {
    return [color, ColorUtils.gradientColor(color)];
  }
}
