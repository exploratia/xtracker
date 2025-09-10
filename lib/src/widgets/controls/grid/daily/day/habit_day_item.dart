import 'package:flutter/material.dart';

import '../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/day_item/day_item.dart';
import '../../../../series/data/view/habit/table/habit_value_renderer.dart';
import '../pixel.dart';
import 'grid_day_item.dart';

class HabitDayItem extends GridDayItem<HabitValue> {
  HabitDayItem(super.dateTimeDayStart, super.seriesDef);

  Pixel toPixel(bool monthly, List<Color> colors) {
    return Pixel<HabitValue>(
      colors: colors,
      backgroundColor: backgroundColor,
      pixelText: count > 0 ? '$count' : null,
      isStartMarker: monthly ? false : dayDate.day == 1,
      seriesValues: dateTimeItems,
      tooltipValueBuilder: (dataValue) => HabitValueRenderer(habitValue: dataValue, seriesDef: seriesDef),
    );
  }

  @override
  String toString() {
    return 'HabitDayItem{date: $dayDate, count: $count}';
  }

  static List<HabitDayItem> buildDayItems(List<HabitValue> seriesData, SeriesDef seriesDef) {
    return DayItem.buildDayItems(
      seriesData,
      (DateTime dayDate) => HabitDayItem(dayDate, seriesDef),
      reversed: true /*reversed - we want to see newest date first*/,
    );
  }
}
