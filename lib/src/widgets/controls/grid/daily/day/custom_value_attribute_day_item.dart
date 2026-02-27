import 'package:flutter/material.dart';

import '../../../../../model/series/attributes/attribute_resolver.dart';
import '../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/day_item/day_item.dart';
import '../../../../../util/globals.dart';
import '../../../attribute/attribute_renderer.dart';
import '../pixel.dart';
import 'grid_day_item.dart';

class CustomValueAttributeDayItem extends GridDayItem<CustomValue> {
  CustomValueAttributeDayItem(super.dateTimeDayStart, super.seriesDef);

  Pixel toPixel(bool monthly, AttributeResolver attributeResolver) {
    List<Color> colors = dateTimeItems.map((e) => attributeResolver.resolve(e.aid)).where((e) => e.aid != Globals.invalid).map((e) => e.color).toList();

    return Pixel<CustomValue>(
      colors: colors,
      backgroundColor: backgroundColor,
      pixelText: null /* count > 0 ? '$count' : null */,
      isStartMarker: monthly ? false : dayDate.day == 1,
      seriesValues: dateTimeItems,
      tooltipValueBuilder: (dataValue) {
        if (dataValue.aid == null || dataValue.aid == Globals.invalid) return const Text("-");
        return AttributeRenderer(
          attribute: attributeResolver.resolve(dataValue.aid),
          maxContentWidth: 120,
          margin: const EdgeInsets.all(2),
        );
      },
    );
  }

  @override
  String toString() {
    return 'CustomValueAttributeDayItem{date: $dayDate, count: $count}';
  }

  static List<CustomValueAttributeDayItem> buildDayItems(List<CustomValue> seriesData, SeriesDef seriesDef) {
    return DayItem.buildDayItems(
      seriesData,
      (DateTime dayDate) => CustomValueAttributeDayItem(dayDate, seriesDef),
      reversed: true /*reversed - we want to see newest date first*/,
    );
  }
}
