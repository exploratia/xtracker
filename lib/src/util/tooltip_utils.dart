import 'package:material_ui/material_ui.dart';

class TooltipUtils {
  static TextStyle tooltipMonospaceStyle = const TextStyle(inherit: true, color: Colors.grey, fontFamily: 'monospace');

  static void updateTooltipMonospaceStyle(BuildContext context) {
    final themeData = Theme.of(context);
    tooltipMonospaceStyle = themeData.tooltipTheme.textStyle!.copyWith(fontFamily: 'monospace');
  }
}
