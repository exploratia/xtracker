import 'package:flutter/material.dart';

import '../../../../../model/series/data/series_data_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/day_item/day_item.dart';
import '../../../../../util/globals.dart';

abstract class GridDayItem<T extends SeriesDataValue> extends DayItem<T> {
  late final Color? backgroundColor;
  final SeriesDef seriesDef;

  GridDayItem(super.dateTime, this.seriesDef) {
    if (dayDate.weekday == DateTime.sunday) {
      backgroundColor = Globals.backgroundColorSunday;
    } else if (dayDate.weekday == DateTime.saturday) {
      backgroundColor = Globals.backgroundColorSaturday;
    } else {
      backgroundColor = null;
    }
  }

  @override
  String toString() {
    return 'GridDayItem{count: $count}';
  }
}
