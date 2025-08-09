import 'package:flutter/material.dart';

import '../../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/tooltip_utils.dart';
import 'daily_check_value_renderer.dart';

class DailyCheckValuesRenderer extends StatelessWidget {
  const DailyCheckValuesRenderer({super.key, required this.dailyCheckValues, required this.seriesViewMetaData});

  final List<DailyCheckValue> dailyCheckValues;
  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    if (dailyCheckValues.isEmpty) return Container();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...dailyCheckValues.map(
          (dcv) => Tooltip(
            message: '${DateTimeUtils.formateDate(dcv.dateTime)}   ${DateTimeUtils.formateTime(dcv.dateTime)}',
            textStyle: TooltipUtils.tooltipMonospaceStyle,
            child: DailyCheckValueRenderer(
              key: Key('dailyCheckValue_${dcv.uuid}'),
              dailyCheckValue: dcv,
              seriesDef: seriesViewMetaData.seriesDef,
              editMode: seriesViewMetaData.editMode,
            ),
          ),
        ),
      ],
    );
  }
}
