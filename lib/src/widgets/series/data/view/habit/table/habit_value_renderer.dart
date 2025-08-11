import 'package:flutter/material.dart';

import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';

class HabitValueRenderer extends StatelessWidget {
  const HabitValueRenderer({super.key, required this.habitValue, this.editMode = false, required this.seriesDef});

  final HabitValue habitValue;
  final bool editMode;
  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var container = Container(
      margin: const EdgeInsets.all(2),
      child: Icon(
        seriesDef.iconData(),
        color: editMode ? themeData.colorScheme.secondary : null,
      ),
    );

    if (editMode) {
      return InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        onTap: () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: habitValue),
        child: container,
      );
    }
    return container;
  }
}
