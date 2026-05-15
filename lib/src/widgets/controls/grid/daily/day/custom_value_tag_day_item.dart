import 'package:flutter/material.dart';

import '../../../../../model/series/tags/tag_resolver.dart';
import '../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/day_item/day_item.dart';
import '../../../../../util/globals.dart';
import '../../../tag/tag_renderer.dart';
import '../pixel.dart';
import 'grid_day_item.dart';

class CustomValueTagDayItem extends GridDayItem<CustomValue> {
  CustomValueTagDayItem(super.dateTimeDayStart, super.seriesDef);

  Pixel toPixel(bool monthly, TagResolver tagResolver) {
    List<Color> colors = dateTimeItems.map((e) => tagResolver.resolve(e.tagId)).where((e) => e.tagId != Globals.invalid).map((e) => e.color).toList();

    return Pixel<CustomValue>(
      colors: colors,
      backgroundColor: backgroundColor,
      pixelText: null /* count > 0 ? '$count' : null */,
      isStartMarker: monthly ? false : dayDate.day == 1,
      seriesValues: dateTimeItems,
      tooltipValueBuilder: (dataValue) {
        if (dataValue.tagId == null || dataValue.tagId == Globals.invalid) return const Text("-");
        return TagRenderer(
          tag: tagResolver.resolve(dataValue.tagId),
          maxContentWidth: 120,
          margin: const EdgeInsets.all(2),
        );
      },
    );
  }

  @override
  String toString() {
    return 'CustomValueTagDayItem{date: $dayDate, count: $count}';
  }

  static List<CustomValueTagDayItem> buildDayItems(List<CustomValue> seriesData, SeriesDef seriesDef) {
    return DayItem.buildDayItems(
      seriesData,
      (DateTime dayDate) => CustomValueTagDayItem(dayDate, seriesDef),
      reversed: true /*reversed - we want to see newest date first*/,
    );
  }
}
