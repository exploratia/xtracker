import 'package:flutter/material.dart';

import '../../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';

class DailyCheckValueRenderer extends StatelessWidget {
  const DailyCheckValueRenderer({super.key, required this.dailyCheckValue, this.editMode = false, required this.seriesDef});

  final DailyCheckValue dailyCheckValue;
  final bool editMode;
  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var container = Container(
      margin: const EdgeInsets.all(2),
      child: Icon(
        Icons.check_box_outlined,
        color: editMode ? themeData.colorScheme.secondary : null,
      ),
    );

    if (editMode) {
      return InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        onTap: () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: dailyCheckValue),
        child: container,
      );
    }
    return container;
  }
}
