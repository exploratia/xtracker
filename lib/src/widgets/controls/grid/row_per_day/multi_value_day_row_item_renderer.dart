import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../util/chart/chart_utils.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/range.dart';
import '../../../../util/theme_utils.dart';
import '../../../series/data/view/series_data_tooltip_content.dart';
import '../../../series/data/view/series_value_renderer.dart';
import '../../range/range_bar.dart';
import '../../renderer/number_gradient_renderer.dart';
import '../../tooltip/lazy_tooltip.dart';
import 'multi_value_day_row_item.dart';

class MultiValueDayRowItemRenderer<T extends SeriesDataValue> extends StatelessWidget {
  const MultiValueDayRowItemRenderer({
    super.key,
    required this.hourly,
    required this.seriesViewMetaData,
    required this.multiValueDayRowItem,
    required this.tooltipValueBuilder,
  });

  final bool hourly;
  final SeriesViewMetaData seriesViewMetaData;
  final MultiValueDayRowItem<T> multiValueDayRowItem;
  final Widget Function(T dataValue) tooltipValueBuilder;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var seriesDef = seriesViewMetaData.seriesDef;

    Widget result;
    if (hourly) {
      var countPerHour = multiValueDayRowItem.countPerHour();
      result = Center(
        child: NumberGradientRenderer(
          numbers: countPerHour,
          baseColor: seriesDef.color,
        ),
      );
    } else {
      // day range
      var rangeMinutesOfDay = Range(
          DateTimeUtils.minutesOfDay(multiValueDayRowItem.minDateTime) / (24 * 60), DateTimeUtils.minutesOfDay(multiValueDayRowItem.maxDateTime) / (24 * 60));
      result = Center(
        child: SizedBox(
          height: 8,
          child: RangeBar(
            value: rangeMinutesOfDay.from,
            value2: rangeMinutesOfDay.to,
            color: seriesDef.color,
          ),
        ),
      );
    }

    if (multiValueDayRowItem.values.isNotEmpty) {
      if (seriesViewMetaData.editMode) {
        result = Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ThemeUtils.borderRadiusSmall),
              gradient: ChartUtils.createLeftToRightGradient(
                [
                  themeData.colorScheme.secondary.withAlpha(0),
                  themeData.colorScheme.secondary,
                  themeData.colorScheme.secondary.withAlpha(0),
                ],
                stops: [0.0, 0.5, 1],
              ),
            ),
            child: result,
          ),
        );

        Function() onTab;
        // only one value -> direct input dlg
        // multiple values -> select value dlg
        if (multiValueDayRowItem.values.length == 1) {
          onTab = () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: multiValueDayRowItem.values.single);
        } else {
          onTab = () async {
            var selected = await Dialogs.showSelectionDialog(
              context: context,
              title: Align(alignment: AlignmentGeometry.topLeft, child: Icon(Icons.edit_outlined, size: ThemeUtils.iconSizeScaled)),
              values: multiValueDayRowItem.values,
              itemBuilder: (context, value) => SeriesValueRenderer(value, seriesDef: seriesDef),
            );
            if (context.mounted && selected != null) {
              return SeriesData.showSeriesDataInputDlg(context, seriesDef, value: selected);
            }
            return;
          };
        }
        result = InkWell(
          borderRadius: ThemeUtils.borderRadiusCircularSmall,
          onTap: onTab,
          child: result,
        );
      }

      result = LazyTooltip(
          child: result, tooltipBuilder: (_) => SeriesDataTooltipContent.buildSeriesValueTooltipWidget(multiValueDayRowItem.values, tooltipValueBuilder));
    }

    return result;
  }
}
