import 'package:flutter/material.dart';

import '../../../../../model/series/settings/daily_life/daily_life_attribute.dart';
import '../../../../../util/chart/chart_utils.dart';
import '../../../../../util/color_utils.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/text/overflow_text.dart';

class DailyLifeAttributeRenderer extends StatelessWidget {
  final DailyLifeAttribute dailyLifeAttribute;

  const DailyLifeAttributeRenderer({super.key, required this.dailyLifeAttribute});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
      decoration: BoxDecoration(
        // color: dailyLifeAttribute.color,
        gradient: ChartUtils.createLeftToRightGradient(buildAttributeGradient(dailyLifeAttribute.color)),
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
      ),
      child: OverflowText(
        expanded: false,
        dailyLifeAttribute.name,
        style: themeData.textTheme.labelMedium?.copyWith(color: ColorUtils.getContrastingTextColor(dailyLifeAttribute.color)),
      ),
    );
  }

  static List<Color>? buildAttributeGradient(Color color) {
    return [color, ColorUtils.gradientColor(color)];
  }
}
