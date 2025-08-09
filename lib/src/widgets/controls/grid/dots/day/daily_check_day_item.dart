import 'package:flutter/material.dart';

import '../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../model/series/data/series_data.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/color_utils.dart';
import '../../../../../util/date_time_utils.dart';
import '../dot.dart';
import './day_item.dart';

class DailyCheckDayItem extends DayItem {
  DailyCheckDayItem(super.dateTime);

  static Color _color1 = Colors.blue;
  static Color _color2 = Colors.blue;
  static bool _showCount = false;

  /// set statics (colors,...) for Dot
  static void updateValuesFromSeries(SeriesDef seriesDef) {
    _color1 = seriesDef.color;
    _color2 = ColorUtils.hue(_color1, 30);
    _showCount = seriesDef.displaySettingsReadonly().dotsViewShowCount;
  }

  @override
  Dot toDot(bool monthly) {
    if (count < 1) return noValueDot(monthly);

    return Dot(
      dotColor1: _color1,
      dotColor2: _color2,
      count: _showCount && count > 1 ? count : null,
      isStartMarker: monthly ? false : dateTime.day == 1,
    );
  }

  @override
  String toString() {
    return 'DailyCheckDayItem{date: $dateTime, count: $count}';
  }

  static List<DailyCheckDayItem> buildDayItems(SeriesData<DailyCheckValue> seriesData) {
    List<DailyCheckDayItem> list = [];

    DailyCheckDayItem? actItem;
    DateTime? actDay;

    DailyCheckDayItem createDayItem(DateTime dateTimeDay) {
      DailyCheckDayItem rowItem = DailyCheckDayItem(dateTimeDay);
      list.add(rowItem);
      return rowItem;
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

      actItem!.increaseCount();
    }

    return list;
  }
}
