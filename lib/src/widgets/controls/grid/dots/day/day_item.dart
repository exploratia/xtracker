import 'package:flutter/material.dart';

import '../../../../../util/date_time_utils.dart';
import '../../../../../util/globals.dart';
import '../dot.dart';

abstract class DayItem {
  late final DateTime dateTime;
  late final Color? backgroundColor;
  int count = 0;

  DayItem(DateTime dateTime) {
    this.dateTime = DateTimeUtils.truncateToDay(dateTime);
    if (dateTime.weekday == DateTime.sunday) {
      backgroundColor = Globals.backgroundColorSunday;
    } else if (dateTime.weekday == DateTime.saturday) {
      backgroundColor = Globals.backgroundColorSaturday;
    } else {
      backgroundColor = null;
    }
  }

  void increaseCount() {
    count++;
  }

  Dot toDot(bool monthly);

  Dot noValueDot(bool monthly) {
    return Dot(dotColor1: Colors.grey.withAlpha(64), isStartMarker: monthly ? false : dateTime.day == 1);
  }

  @override
  String toString() {
    return 'DayItem{count: $count}';
  }
}
