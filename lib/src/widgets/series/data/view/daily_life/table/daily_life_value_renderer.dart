import 'package:flutter/material.dart';

import '../../../../../../model/series/attributes/attribute_resolver.dart';
import '../../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';
import '../../../../../../util/chart/chart_utils.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/media_query_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../../util/tooltip_utils.dart';
import '../../../../../controls/attribute/attribute_renderer.dart';

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
    this.maxContentWidth = 80,
  });

  final DailyLifeValue dailyLifeValue;
  final bool editMode;
  final SeriesDef seriesDef;
  final bool wrapWithDateTimeTooltip;
  final AttributeResolver dailyLifeAttributeResolver;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var resolvedAttribute = dailyLifeAttributeResolver.resolve(dailyLifeValue);
    Widget result = Container(
      decoration: editMode
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
          child: AttributeRenderer(
            attribute: resolvedAttribute,
            maxContentWidth: maxContentWidth,
          ),
        ),
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
