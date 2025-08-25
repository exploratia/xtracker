import 'package:flutter/material.dart';

import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/tooltip_utils.dart';

class HabitValueRenderer extends StatelessWidget {
  static int height = 28;

  const HabitValueRenderer({
    super.key,
    required this.habitValue,
    required this.seriesDef,
    this.editMode = false,
    this.centered = false,
    this.wrapWithDateTimeTooltip = false,
  });

  final HabitValue habitValue;
  final bool editMode;
  final SeriesDef seriesDef;
  final bool centered;
  final bool wrapWithDateTimeTooltip;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    Widget result = Container(
      margin: const EdgeInsets.all(2),
      child: Icon(
        seriesDef.iconData(),
        color: editMode ? themeData.colorScheme.secondary : null,
      ),
    );

    if (editMode) {
      result = InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        onTap: () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: habitValue),
        child: result,
      );
    }

    if (wrapWithDateTimeTooltip) {
      result = Tooltip(
        message: '${DateTimeUtils.formateDate(habitValue.dateTime)}   ${DateTimeUtils.formateTime(habitValue.dateTime)}',
        textStyle: TooltipUtils.tooltipMonospaceStyle,
        child: result,
      );
    }

    return result;
  }
}
