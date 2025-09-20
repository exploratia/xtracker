import 'package:flutter/material.dart';

import '../../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';
import '../../../../../../model/series/settings/daily_life/daily_life_attribute_resolver.dart';
import '../../../../../../util/chart/chart_utils.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/media_query_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../../util/tooltip_utils.dart';
import '../daily_life_attribute_renderer.dart';

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
    required this.dailyLifeAttributeResolver,
  });

  final DailyLifeValue dailyLifeValue;
  final bool editMode;
  final SeriesDef seriesDef;
  final bool wrapWithDateTimeTooltip;
  final DailyLifeAttributeResolver dailyLifeAttributeResolver;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var resolvedAttribute = dailyLifeAttributeResolver.resolve(dailyLifeValue);
    Widget result = Container(
      decoration: editMode
          ? BoxDecoration(
              gradient: ChartUtils.createLeftToRightGradient(
                [themeData.colorScheme.secondary.withAlpha(0), themeData.colorScheme.secondary, themeData.colorScheme.secondary.withAlpha(0)],
                stops: [0.1, 0.5, 0.9],
              ),
            )
          : null,
      margin: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DailyLifeAttributeRenderer(dailyLifeAttribute: resolvedAttribute),
        ],
      ),
    );

    if (editMode) {
      result = InkWell(
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
        onTap: () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: dailyLifeValue),
        child: result,
      );
    }

    if (wrapWithDateTimeTooltip) {
      result = Tooltip(
        message: '${DateTimeUtils.formatDate(dailyLifeValue.dateTime)}   ${DateTimeUtils.formatTime(dailyLifeValue.dateTime)}\n ${resolvedAttribute.name}',
        textStyle: TooltipUtils.tooltipMonospaceStyle,
        child: result,
      );
    }

    return result;
  }
}
