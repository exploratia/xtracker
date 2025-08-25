import 'package:flutter/material.dart';

import '../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/date_time_utils.dart';
import '../../../../series/data/view/habit/table/habit_value_renderer.dart';
import '../pixel.dart';
import './day_item.dart';

class HabitDayItem extends DayItem<HabitValue> {
  HabitDayItem(super.dateTimeDayStart, super.seriesDef);

  Pixel toPixel(bool monthly, List<Color> colors) {
    return Pixel<HabitValue>(
      colors: colors,
      backgroundColor: backgroundColor,
      pixelText: count > 0 ? '$count' : null,
      isStartMarker: monthly ? false : dateTimeDayStart.day == 1,
      seriesValues: seriesValues,
      tooltipValueBuilder: (dataValue) => HabitValueRenderer(habitValue: dataValue, seriesDef: seriesDef),
    );
  }

  @override
  String toString() {
    return 'HabitDayItem{date: $dateTimeDayStart, count: $count}';
  }

  static List<HabitDayItem> buildDayItems(List<HabitValue> seriesData, SeriesDef seriesDef) {
    List<HabitDayItem> list = [];

    HabitDayItem? actItem;
    DateTime? actDay;

    HabitDayItem createDayItem(DateTime dateTimeDayStart) {
      HabitDayItem dayItem = HabitDayItem(dateTimeDayStart, seriesDef);
      list.add(dayItem);
      return dayItem;
    }

    for (var item in seriesData.reversed) {
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
