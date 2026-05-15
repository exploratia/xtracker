import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';
import 'progress_bar.dart';

class RatioLabeledProgressBar extends StatelessWidget {
  const RatioLabeledProgressBar({super.key, required this.color, required this.value, required this.total});

  final Color color;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    var percentage = value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProgressBar(
          value: percentage,
          color: color,
          padding: const EdgeInsets.only(
            top: ThemeUtils.verticalSpacingSmall,
            bottom: ThemeUtils.verticalSpacingSmall,
            left: ThemeUtils.horizontalSpacing,
            right: ThemeUtils.horizontalSpacing,
          ),
        ),
        Row(
          spacing: ThemeUtils.horizontalSpacingSmall,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: ThemeUtils.horizontalSpacing),
              child: Text('${(percentage * 100).toInt()}%'),
            ),
            Padding(
              padding: const EdgeInsets.only(right: ThemeUtils.horizontalSpacing),
              child: Text(
                '$value / $total',
                softWrap: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
