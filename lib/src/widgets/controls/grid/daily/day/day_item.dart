import 'package:flutter/material.dart';

import '../../../../../model/series/data/series_data_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/date_time_utils.dart';
import '../../../../../util/globals.dart';

abstract class DayItem<T extends SeriesDataValue> {
  late final DateTime dateTimeDayStart;
  late final Color? backgroundColor;
  final SeriesDef seriesDef;
  final List<T> seriesValues = [];

  DayItem(DateTime dateTimeDayStart, this.seriesDef) {
    this.dateTimeDayStart = DateTimeUtils.truncateToDay(dateTimeDayStart);
    if (dateTimeDayStart.weekday == DateTime.sunday) {
      backgroundColor = Globals.backgroundColorSunday;
    } else if (dateTimeDayStart.weekday == DateTime.saturday) {
      backgroundColor = Globals.backgroundColorSaturday;
    } else {
      backgroundColor = null;
    }
  }

  void addValue(T value) {
    seriesValues.add(value);
  }

  int get count {
    return seriesValues.length;
  }

  @override
  String toString() {
    return 'DayItem{count: $count}';
  }
}
