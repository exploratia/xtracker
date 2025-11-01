import '../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/color_utils.dart';
import '../../../../../util/day_item/day_item.dart';
import '../../../../series/data/view/daily_check/table/daily_check_value_renderer.dart';
import '../pixel.dart';
import 'grid_day_item.dart';

class DailyCheckDayItem extends GridDayItem<DailyCheckValue> {
  DailyCheckDayItem(super.dateTimeDayStart, super.seriesDef);

  Pixel toPixel(bool monthly) {
    var colors = [seriesDef.color];
    if (count > 1) {
      colors[0] = ColorUtils.gradientColor(colors[0]);
    }
    return Pixel<DailyCheckValue>(
      colors: colors,
      backgroundColor: backgroundColor,
      pixelText: count > 1 ? '$count' : null,
      isStartMarker: monthly ? false : dayDate.day == 1,
      seriesValues: dateTimeItems,
      tooltipValueBuilder: (dataValue) => DailyCheckValueRenderer(dailyCheckValue: dataValue, seriesDef: seriesDef),
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
