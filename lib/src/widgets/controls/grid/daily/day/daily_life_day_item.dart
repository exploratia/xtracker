import 'package:flutter/material.dart';

import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../model/series/settings/daily_life/daily_life_attribute_resolver.dart';
import '../../../../../util/day_item/day_item.dart';
import '../../../../series/data/view/daily_life/table/daily_life_value_renderer.dart';
import '../pixel.dart';
import 'grid_day_item.dart';

class DailyLifeDayItem extends GridDayItem<DailyLifeValue> {
  DailyLifeDayItem(super.dateTimeDayStart, super.seriesDef);

  Pixel toPixel(bool monthly, DailyLifeAttributeResolver dailyLifeAttributeResolver) {
    List<Color> colors = dateTimeItems.map((e) => dailyLifeAttributeResolver.resolve(e.attributeUuid).color).toList();

    return Pixel<DailyLifeValue>(
      colors: colors,
      backgroundColor: backgroundColor,
      pixelText: null /* count > 0 ? '$count' : null */,
      isStartMarker: monthly ? false : dayDate.day == 1,
      seriesValues: dateTimeItems,
      tooltipValueBuilder: (dataValue) => DailyLifeValueRenderer(
        dailyLifeValue: dataValue,
        seriesDef: seriesDef,
        dailyLifeAttributeResolver: dailyLifeAttributeResolver,
      ),
    );
  }

  @override
  String toString() {
    return 'DailyLifeDayItem{date: $dayDate, count: $count}';
  }

  static List<DailyLifeDayItem> buildDayItems(List<DailyLifeValue> seriesData, SeriesDef seriesDef) {
    return DayItem.buildDayItems(
      seriesData,
      (DateTime dayDate) => DailyLifeDayItem(dayDate, seriesDef),
      reversed: true /*reversed - we want to see newest date first*/,
    );
  }
}
