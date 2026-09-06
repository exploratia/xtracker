import 'package:material_ui/material_ui.dart';

import '../../../util/theme_utils.dart';

class LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const LegendItem({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Row(
      mainAxisSize: .min,
      crossAxisAlignment: .center,
      spacing: ThemeUtils.horizontalSpacingSmall,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          height: 8,
          width: 16,
        ),
        Text(
          label,
          style: themeData.textTheme.labelSmall,
        ),
      ],
    );
  }
}
