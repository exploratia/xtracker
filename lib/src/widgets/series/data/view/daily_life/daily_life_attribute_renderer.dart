import 'package:flutter/material.dart';

import '../../../../../model/series/settings/daily_life/daily_life_attribute.dart';
import '../../../../../util/color_utils.dart';
import '../../../../../util/theme_utils.dart';

class DailyLifeAttributeRenderer extends StatelessWidget {
  final DailyLifeAttribute dailyLifeAttribute;

  const DailyLifeAttributeRenderer({super.key, required this.dailyLifeAttribute});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: dailyLifeAttribute.color, borderRadius: ThemeUtils.borderRadiusCircularSmall),
      child: Padding(
        padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
        child: Text(
          dailyLifeAttribute.name,
          style: themeData.textTheme.labelMedium?.copyWith(color: ColorUtils.getContrastingTextColor(dailyLifeAttribute.color)),
        ),
      ),
    );
  }
}
