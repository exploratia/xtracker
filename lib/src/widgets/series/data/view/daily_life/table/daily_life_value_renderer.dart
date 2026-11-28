import 'package:material_ui/material_ui.dart';

import '../../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';
import '../../../../../../model/series/tags/tag_resolver.dart';
import '../../../../../../util/chart/chart_utils.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/media_query_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../../util/tooltip_utils.dart';
import '../../../../../controls/tag/tag_renderer.dart';
import '../../series_value_actions.dart';

class DailyLifeValueRenderer extends StatelessWidget {
  static int get height {
    return (28 * MediaQueryUtils.textScaleFactor).ceil();
  }

  const DailyLifeValueRenderer({
    super.key,
    required this.dailyLifeValue,
    required this.seriesDef,
    this.editMode = false,
    this.wrapWithDateTimeTooltip = false,
    required this.dailyLifeTagResolver,
    this.maxContentWidth = 80,
    this.enableActions = false,
  });

  final DailyLifeValue dailyLifeValue;
  final bool editMode;
  final SeriesDef seriesDef;
  final bool wrapWithDateTimeTooltip;
  final TagResolver dailyLifeTagResolver;
  final double maxContentWidth;
  final bool enableActions;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var resolvedTag = dailyLifeTagResolver.resolve(dailyLifeValue);
    Widget buildValue(bool selected) => Container(
      decoration: selected
          ? BoxDecoration(
              border: Border.all(
                color: themeData.colorScheme.secondary,
              ),
              borderRadius: BorderRadius.circular(ThemeUtils.borderRadiusSmall),
              gradient: ChartUtils.createLeftToRightGradient(
                [themeData.colorScheme.secondary, themeData.colorScheme.secondary.withAlpha(0), themeData.colorScheme.secondary],
                stops: [0.0, 0.5, 1.0],
              ),
            )
          : BoxDecoration(
              border: Border.all(
                color: Colors.transparent,
              ),
            ),
      margin: const EdgeInsets.all(2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: TagRenderer(
            tag: resolvedTag,
            maxContentWidth: maxContentWidth,
          ),
        ),
      ),
    );

    Widget result;

    if (enableActions) {
      result = SeriesValueActions(
        seriesDef: seriesDef,
        value: dailyLifeValue,
        onTap: editMode ? () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: dailyLifeValue) : null,
        childBuilder: (_, selected) => buildValue(editMode || selected),
      );
    } else {
      result = buildValue(editMode);
    }

    if (wrapWithDateTimeTooltip) {
      result = Tooltip(
        message: '${DateTimeUtils.formatDate(dailyLifeValue.dateTime)}   ${DateTimeUtils.formatTime(dailyLifeValue.dateTime)}\n ${resolvedTag.name}',
        textStyle: TooltipUtils.tooltipMonospaceStyle,
        child: result,
      );
    }

    return result;
  }
}
