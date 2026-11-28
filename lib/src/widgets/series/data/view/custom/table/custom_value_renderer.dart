import 'package:material_ui/material_ui.dart';

import '../../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../../model/series/data/monthly/monthly_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';
import '../../../../../../util/chart/chart_utils.dart';
import '../../../../../../util/color_utils.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/media_query_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../../util/tooltip_utils.dart';
import '../../../../../controls/text/overflow_text.dart';
import '../../series_value_actions.dart';

class CustomValueRenderer extends StatelessWidget {
  static int get height {
    return (28 * MediaQueryUtils.textScaleFactor).ceil();
  }

  const CustomValueRenderer({
    super.key,
    required this.customValue,
    required this.seriesDef,
    this.editMode = false,
    this.wrapWithDateTimeTooltip = false,
    this.enableActions = false,
  });

  final CustomValue customValue;
  final bool editMode;
  final SeriesDef seriesDef;
  final bool wrapWithDateTimeTooltip;
  final bool enableActions;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    Widget buildValue(bool selected) {
      if (customValue.values.length == 1 && !selected) {
        var seriesItem = seriesDef.seriesItems.first;

        return Container(
          padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
          decoration: BoxDecoration(
            gradient: ChartUtils.createLeftToRightGradient(ColorUtils.gradientFromColor(seriesItem.color)),
            borderRadius: ThemeUtils.borderRadiusCircularSmall,
          ),
          child: OverflowText(
            expanded: false,
            "${customValue.values.values.first}${seriesDef.seriesItems.first.unitSuffix()}",
            style: themeData.textTheme.labelMedium?.copyWith(color: ColorUtils.getContrastingTextColor(seriesItem.color)),
          ),
        );
      }
      return Container(
        margin: const EdgeInsets.all(2),
        child: Icon(
          size: ThemeUtils.iconSizeScaled,
          seriesDef.iconData(),
          color: selected ? themeData.colorScheme.secondary : null,
        ),
      );
    }

    Widget result;

    if (enableActions) {
      result = SeriesValueActions(
        seriesDef: seriesDef,
        value: customValue,
        onTap: editMode ? () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: customValue) : null,
        childBuilder: (_, selected) => buildValue(editMode || selected),
      );
    } else {
      result = buildValue(editMode);
    }

    if (wrapWithDateTimeTooltip) {
      var msg = (customValue is MonthlyValue)
          ? DateTimeUtils.formatMonthYear(customValue.dateTime)
          : '${DateTimeUtils.formatDate(customValue.dateTime)}   ${DateTimeUtils.formatTime(customValue.dateTime)}';
      var tooltip = Tooltip(
        message: msg,
        textStyle: TooltipUtils.tooltipMonospaceStyle,
        child: result,
      );
      result = tooltip;
    }

    return result;
  }
}
