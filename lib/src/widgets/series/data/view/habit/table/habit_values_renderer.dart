import 'package:flutter/material.dart';

import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/tooltip_utils.dart';
import 'habit_value_renderer.dart';

class HabitValuesRenderer extends StatelessWidget {
  const HabitValuesRenderer({super.key, required this.habitValues, required this.seriesViewMetaData});

  final List<HabitValue> habitValues;
  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    if (habitValues.isEmpty) return Container();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...habitValues.map(
          (hv) => Tooltip(
            message: '${DateTimeUtils.formateDate(hv.dateTime)}   ${DateTimeUtils.formateTime(hv.dateTime)}',
            textStyle: TooltipUtils.tooltipMonospaceStyle,
            child: HabitValueRenderer(
              key: Key('habitValue_${hv.uuid}'),
              habitValue: hv,
              seriesDef: seriesViewMetaData.seriesDef,
              editMode: seriesViewMetaData.editMode,
            ),
          ),
        ),
      ],
    );
  }
}
