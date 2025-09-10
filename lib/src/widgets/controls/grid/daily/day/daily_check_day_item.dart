import 'package:flutter/material.dart';

import '../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/color_utils.dart';
import '../../../../../util/day_item/day_item.dart';
import '../../../../series/data/view/daily_check/table/daily_check_value_renderer.dart';
import '../dot.dart';
import 'grid_day_item.dart';

class DailyCheckDayItem extends GridDayItem<DailyCheckValue> {
  DailyCheckDayItem(super.dateTimeDayStart, super.seriesDef);

  static Color _color1 = Colors.blue;
  static Color _color2 = Colors.blue;
  static bool _showCount = false;

  /// set statics (colors,...) for Dot
  static void updateValuesFromSeries(SeriesDef seriesDef) {
    _color1 = seriesDef.color;
    _color2 = ColorUtils.hue(_color1, 30);
    _showCount = seriesDef.displaySettingsReadonly().dotsViewShowCount;
  }

  Dot toDot(bool monthly) {
    return Dot(
      dotColor1: _color1,
      dotColor2: _color2,
      showCount: _showCount,
      isStartMarker: monthly ? false : dayDate.day == 1,
      seriesValues: dateTimeItems,
      tooltipValueBuilder: (dataValue) => DailyCheckValueRenderer(dailyCheckValue: dataValue as DailyCheckValue, seriesDef: seriesDef),
    );
  }

  @override
  String toString() {
    return 'DailyCheckDayItem{date: $dayDate, count: $count}';
  }

  static List<DailyCheckDayItem> buildDayItems(List<DailyCheckValue> seriesData, SeriesDef seriesDef) {
    return DayItem.buildDayItems(
      seriesData,
      (DateTime dayDate) => DailyCheckDayItem(dayDate, seriesDef),
      reversed: true /*reversed - we want to see newest date first*/,
    );
  }
}
