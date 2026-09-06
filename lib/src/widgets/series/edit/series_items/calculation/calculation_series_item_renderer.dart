import 'package:material_ui/material_ui.dart';

import '../../../../../model/series/seriesItem/series_item.dart';
import '../../../../../util/chart/chart_utils.dart';
import '../../../../../util/color_utils.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/text/overflow_text.dart';

class CalculationSeriesItemRenderer extends StatelessWidget {
  final SeriesItem seriesItem;
  final bool usePreviousInput;

  const CalculationSeriesItemRenderer({
    super.key,
    required this.seriesItem,
    this.usePreviousInput = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    Widget widget = Container(
      padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
      decoration: BoxDecoration(
        gradient: ChartUtils.createLeftToRightGradient(buildGradient(seriesItem.color)),
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
      ),
      child: OverflowText(
        expanded: false,
        seriesItem.name,
        style: themeData.textTheme.labelMedium?.copyWith(color: ColorUtils.getContrastingTextColor(seriesItem.color)),
      ),
    );

    if (usePreviousInput) {
      widget = Row(
        children: [
          const Icon(
            Icons.arrow_back_outlined,
            color: Colors.grey,
          ),
          widget,
        ],
      );
    }

    return widget;
  }

  static List<Color>? buildGradient(Color color) {
    return [color, ColorUtils.gradientColor(color)];
  }
}
