import 'package:flutter/material.dart';

import '../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../model/series/data/series_data.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/color_utils.dart';
import '../../../../../util/date_time_utils.dart';
import '../dot.dart';
import './day_item.dart';

class DailyCheckDayItem extends DayItem {
  DailyCheckDayItem(super.dateTimeDayStart);

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
      showCount: _showCount,
      isStartMarker: monthly ? false : dateTimeDayStart.day == 1,
      seriesValues: seriesValues,
    );
  }

  @override
  String toString() {
    return 'DailyCheckDayItem{date: $dateTimeDayStart, count: $count}';
  }

  static List<DailyCheckDayItem> buildDayItems(SeriesData<DailyCheckValue> seriesData) {
    List<DailyCheckDayItem> list = [];

    DailyCheckDayItem? actItem;
    DateTime? actDay;

    DailyCheckDayItem createDayItem(DateTime dateTimeDayStart) {
      DailyCheckDayItem dayItem = DailyCheckDayItem(dateTimeDayStart);
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
