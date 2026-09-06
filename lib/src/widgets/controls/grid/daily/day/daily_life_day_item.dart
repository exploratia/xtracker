import 'package:material_ui/material_ui.dart';

import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../model/series/tags/tag_resolver.dart';
import '../../../../../util/day_item/day_item.dart';
import '../../../../series/data/view/daily_life/table/daily_life_value_renderer.dart';
import '../pixel.dart';
import 'grid_day_item.dart';

class DailyLifeDayItem extends GridDayItem<DailyLifeValue> {
  DailyLifeDayItem(super.dateTimeDayStart, super.seriesDef);

  Pixel toPixel(bool monthly, TagResolver dailyLifeTagResolver) {
    List<Color> colors = dateTimeItems.map((e) => dailyLifeTagResolver.resolve(e.tagId).color).toList();

    return Pixel<DailyLifeValue>(
      colors: colors,
      backgroundColor: backgroundColor,
      pixelText: null /* count > 0 ? '$count' : null */,
      isStartMarker: monthly ? false : dayDate.day == 1,
      seriesValues: dateTimeItems,
      tooltipValueBuilder: (dataValue) => DailyLifeValueRenderer(
        dailyLifeValue: dataValue,
        seriesDef: seriesDef,
        dailyLifeTagResolver: dailyLifeTagResolver,
        maxContentWidth: 120,
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
