import 'package:material_ui/material_ui.dart';

import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/media_query_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../../util/tooltip_utils.dart';
import '../../series_value_actions.dart';

class HabitValueRenderer extends StatelessWidget {
  static int get height {
    return (28 * MediaQueryUtils.textScaleFactor).ceil();
  }

  const HabitValueRenderer({
    super.key,
    required this.habitValue,
    required this.seriesDef,
    this.editMode = false,
    this.wrapWithDateTimeTooltip = false,
    this.enableActions = false,
  });

  final HabitValue habitValue;
  final bool editMode;
  final SeriesDef seriesDef;
  final bool wrapWithDateTimeTooltip;
  final bool enableActions;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    Widget buildValue(bool selected) => Container(
      margin: const EdgeInsets.all(2),
      child: Icon(
        size: ThemeUtils.iconSizeScaled,
        seriesDef.iconData(),
        color: selected ? themeData.colorScheme.secondary : null,
      ),
    );

    Widget result;

    if (enableActions) {
      result = SeriesValueActions(
        seriesDef: seriesDef,
        value: habitValue,
        onTap: editMode ? () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: habitValue) : null,
        childBuilder: (_, selected) => buildValue(editMode || selected),
      );
    } else {
      result = buildValue(editMode);
    }

    if (wrapWithDateTimeTooltip) {
      result = Tooltip(
        message: '${DateTimeUtils.formatDate(habitValue.dateTime)}   ${DateTimeUtils.formatTime(habitValue.dateTime)}',
        textStyle: TooltipUtils.tooltipMonospaceStyle,
        child: result,
      );
    }

    return result;
  }
}
