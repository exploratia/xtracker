import 'package:flutter/material.dart';

import '../../../util/chart/chart_utils.dart';
import '../../../util/theme_utils.dart';

class AppBarActionsDivider extends StatelessWidget {
  const AppBarActionsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Row(
      spacing: 0,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 1, // Divider thickness
          decoration: BoxDecoration(
            gradient: ChartUtils.createTopToBottomGradient(
              [
                Colors.transparent,
                Colors.transparent,
                Colors.black12,
                Colors.black38,
                Colors.black12,
                Colors.transparent,
                Colors.transparent,
              ],
            ),
          ),
          margin: const EdgeInsets.only(left: ThemeUtils.defaultPadding), // Spacing
        ),
        Container(
          width: 1, // Divider thickness
          decoration: BoxDecoration(
            gradient: ChartUtils.createTopToBottomGradient(
              [
                Colors.transparent,
                Colors.transparent,
                Colors.white24,
                Colors.white54,
                Colors.white24,
                Colors.transparent,
                Colors.transparent,
              ],
            ),
          ),
          margin: const EdgeInsets.only(right: ThemeUtils.defaultPadding), // Spacing
        ),
      ],
    );
  }
}
