import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data_value.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/pair.dart';
import '../../../../util/theme_utils.dart';
import '../../../../util/tooltip_utils.dart';

class SeriesDataTooltipContent {
  /// create one tooltip for the given series value(s) which contains the day (of the first value)
  /// and the times for all values
  /// and optional for each value Widget behind the time.
  static Widget buildSeriesValueTooltipWidget<T extends SeriesDataValue>(List<T> seriesValues, Widget? Function(T dataValue)? tooltipValueBuilder) {
    List<Widget> columnChildren = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: ThemeUtils.fontSizeBodyS),
          const SizedBox(width: ThemeUtils.horizontalSpacingSmall),
          Text(DateTimeUtils.formatDateWithDay(seriesValues.first.dateTime), style: TooltipUtils.tooltipMonospaceStyle),
        ],
      ),
      const SizedBox(height: ThemeUtils.verticalSpacingSmall),
    ];

    // bring all times to same length for showing a nice table like tooltip
    List<Pair<String, Widget?>> timeValuePairs = [];

    for (var value in seriesValues) {
      Widget? valueWidget = tooltipValueBuilder != null ? tooltipValueBuilder(value) : null;
      timeValuePairs.add(Pair(DateTimeUtils.formatTime(value.dateTime), valueWidget));
    }

    final maxLength = timeValuePairs.map((p) => p.k.length).reduce((a, b) => a > b ? a : b);
    int c = 0;
    for (var timeValuePair in timeValuePairs) {
      if (c >= 9) {
        columnChildren.add(Text('...', style: TooltipUtils.tooltipMonospaceStyle));
        break;
      }
      columnChildren.add(_tooltipValueLineWidget(timeValuePair.k.padLeft(maxLength), timeValuePair.v));
      c++;
    }

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: columnChildren);
  }

  static Widget _tooltipValueLineWidget(String time, Widget? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time_outlined, size: ThemeUtils.fontSizeBodyS),
        const SizedBox(width: ThemeUtils.horizontalSpacingSmall),
        Text(time, style: TooltipUtils.tooltipMonospaceStyle),
        if (value != null) const SizedBox(width: ThemeUtils.horizontalSpacingLarge),
        if (value != null) value,
      ],
    );
  }
}
