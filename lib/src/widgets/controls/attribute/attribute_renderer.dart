import 'package:flutter/material.dart';

import '../../../model/series/attributes/attribute.dart';
import '../../../util/chart/chart_utils.dart';
import '../../../util/color_utils.dart';
import '../../../util/theme_utils.dart';
import '../text/overflow_text.dart';

class AttributeRenderer extends StatelessWidget {
  final Attribute attribute;

  const AttributeRenderer({super.key, required this.attribute});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
      decoration: BoxDecoration(
        // color: dailyLifeAttribute.color,
        gradient: ChartUtils.createLeftToRightGradient(buildAttributeGradient(attribute.color)),
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
      ),
      child: OverflowText(
        expanded: false,
        attribute.name,
        style: themeData.textTheme.labelMedium?.copyWith(color: ColorUtils.getContrastingTextColor(attribute.color)),
      ),
    );
  }

  static List<Color>? buildAttributeGradient(Color color) {
    return [color, ColorUtils.gradientColor(color)];
  }
}
