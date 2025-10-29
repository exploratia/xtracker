import 'package:flutter/material.dart';

import '../../../../../model/series/data/series_data_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/color_utils.dart';
import '../../../../../util/day_item/day_item.dart';

abstract class GridDayItem<T extends SeriesDataValue> extends DayItem<T> {
  late final Color? backgroundColor;
  final SeriesDef seriesDef;

  GridDayItem(super.dateTime, this.seriesDef) {
    backgroundColor = ColorUtils.weekdayBackgroundColor(dayDate);
  }

  @override
  String toString() {
    return 'GridDayItem{count: $count}';
  }
}
