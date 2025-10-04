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
          ),
        ),
        Row(
          spacing: ThemeUtils.horizontalSpacingLarge,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 70,
              child: Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: ThemeUtils.defaultPadding),
                  child: Text('${(percentage * 100).toInt()}%'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: ThemeUtils.defaultPadding),
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
