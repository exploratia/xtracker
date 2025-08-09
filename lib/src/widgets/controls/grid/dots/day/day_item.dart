import 'package:flutter/material.dart';

import '../../../../../model/series/data/series_data_value.dart';
import '../../../../../util/date_time_utils.dart';
import '../../../../../util/globals.dart';
import '../dot.dart';

abstract class DayItem {
  late final DateTime dateTimeDayStart;
  late final Color? backgroundColor;
  final List<SeriesDataValue> seriesValues = [];

  DayItem(DateTime dateTimeDayStart) {
    this.dateTimeDayStart = DateTimeUtils.truncateToDay(dateTimeDayStart);
    if (dateTimeDayStart.weekday == DateTime.sunday) {
      backgroundColor = Globals.backgroundColorSunday;
    } else if (dateTimeDayStart.weekday == DateTime.saturday) {
      backgroundColor = Globals.backgroundColorSaturday;
    } else {
      backgroundColor = null;
    }
  }

  void addValue(SeriesDataValue value) {
    seriesValues.add(value);
  }

  int get count {
    return seriesValues.length;
  }

  Dot toDot(bool monthly);

  Dot noValueDot(bool monthly) {
    return Dot(
      dotColor1: Colors.grey.withAlpha(64),
      isStartMarker: monthly ? false : dateTimeDayStart.day == 1,
      seriesValues: [],
    );
  }

  @override
  String toString() {
    return 'DayItem{count: $count}';
  }
}
