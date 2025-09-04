import 'package:flutter/material.dart';

import '../../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/media_query_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../../util/tooltip_utils.dart';

class DailyCheckValueRenderer extends StatelessWidget {
  static int get height {
    return (28 * MediaQueryUtils.textScaleFactor).ceil();
  }

  const DailyCheckValueRenderer({
    super.key,
    required this.dailyCheckValue,
    required this.seriesDef,
    this.editMode = false,
    this.centered = false,
    this.wrapWithDateTimeTooltip = false,
  });

  final DailyCheckValue dailyCheckValue;
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
        size: ThemeUtils.iconSizeScaled,
        Icons.check_box_outlined,
        color: editMode ? themeData.colorScheme.secondary : null,
      ),
    );

    if (editMode) {
      result = InkWell(
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
        onTap: () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: dailyCheckValue),
        child: result,
      );
    }

    if (wrapWithDateTimeTooltip) {
      result = Tooltip(
        message: '${DateTimeUtils.formateDate(dailyCheckValue.dateTime)}   ${DateTimeUtils.formateTime(dailyCheckValue.dateTime)}',
        textStyle: TooltipUtils.tooltipMonospaceStyle,
        child: result,
      );
    }

    return result;
  }
}
