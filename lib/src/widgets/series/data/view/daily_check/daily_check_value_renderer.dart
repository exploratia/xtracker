import 'package:flutter/material.dart';

import '../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../model/series/data/series_data.dart';
import '../../../../../model/series/series_def.dart';

class DailyCheckValueRenderer extends StatelessWidget {
  const DailyCheckValueRenderer({super.key, required this.dailyCheckValue, this.editMode, required this.seriesDef});

  final DailyCheckValue dailyCheckValue;
  final bool? editMode;
  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    var container = Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: const Icon(Icons.check_box_outlined),
    );

    if (editMode != null && editMode!) {
      return InkWell(
        onTap: () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: dailyCheckValue),
        child: container,
      );
    }
    return container;
  }
}
