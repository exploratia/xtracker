import 'package:flutter/material.dart';

import '../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../model/series/data/series_data.dart';
import '../../../../../util/date_time_utils.dart';
import '../dot.dart';
import '../pixel.dart';
import './day_item.dart';

class HabitDayItem extends DayItem {
  HabitDayItem(super.dateTimeDayStart);

  @override
  Dot toDot(bool monthly) {
    throw UnimplementedError();
    // if (count < 1) return noValueDot(monthly);
    //
    // return Dot(
    //   dotColor1: Colors.blueAccent,
    //   dotColor2: Colors.blue,
    //   showCount: true,
    //   isStartMarker: monthly ? false : dateTimeDayStart.day == 1,
    //   seriesValues: seriesValues,
    // );
  }

  Widget toPixel(bool monthly, List<Color> colors) {
    return Pixel(
      colors: colors,
      backgroundColor: backgroundColor,
      pixelText: count > 0 ? '$count' : null,
      isStartMarker: monthly ? false : dateTimeDayStart.day == 1,
      seriesValues: seriesValues,
    );
  }

  @override
  String toString() {
    return 'HabitDayItem{date: $dateTimeDayStart, count: $count}';
  }

  static List<HabitDayItem> buildDayItems(SeriesData<HabitValue> seriesData) {
    List<HabitDayItem> list = [];

    HabitDayItem? actItem;
    DateTime? actDay;

    HabitDayItem createDayItem(DateTime dateTimeDayStart) {
      HabitDayItem dayItem = HabitDayItem(dateTimeDayStart);
      list.add(dayItem);
      return dayItem;
    }

    for (var item in seriesData.data.reversed) {
      DateTime dateDay = DateTimeUtils.truncateToDay(item.dateTime);
      actDay ??= dateDay;

      actItem ??= createDayItem(dateDay);

      // not matching date - create (empty)
      while (actDay!.isAfter(dateDay)) {
        actDay = DateTimeUtils.dayBefore(actDay);
        actItem = createDayItem(actDay);
      }

      actItem!.addValue(item);
    }

    return list;
  }
}
