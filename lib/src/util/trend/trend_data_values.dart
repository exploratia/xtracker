import '../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../model/series/data/daily_check/daily_check_value.dart';
import '../../model/series/data/habit/habit_value.dart';
import '../../model/series/data/series_data_value.dart';
import '../date_time_utils.dart';
import '../pair.dart';
import 'trend_data_value.dart';

class TrendDataValues {
  final List<TrendDataValue> values;
  late final double xOrigin;

  TrendDataValues(this.values) {
    xOrigin = values.first.x;
  }

  @override
  String toString() {
    return 'TrendDataValues{values: $values, xOrigin: $xOrigin}';
  }

  static Pair<TrendDataValues, TrendDataValues> buildForBloodPressure(List<BloodPressureValue> seriesDataValues) {
    List<TrendDataValue> high = [];
    List<TrendDataValue> low = [];
    for (var v in seriesDataValues) {
      high.add(TrendDataValue(v.dateTime.millisecondsSinceEpoch.toDouble(), v.high.toDouble()));
      low.add(TrendDataValue(v.dateTime.millisecondsSinceEpoch.toDouble(), v.low.toDouble()));
    }
    return Pair(TrendDataValues(high), TrendDataValues(low));
  }

  static TrendDataValues buildForDailyCheck(List<DailyCheckValue> seriesDataValues) {
    var dayItems = _DayItem.buildDayItems(seriesDataValues);
    return TrendDataValues(dayItems.map((v) => v.trendDataValue).toList());
  }

  static TrendDataValues buildForHabit(List<HabitValue> seriesDataValues) {
    var dayItems = _DayItem.buildDayItems(seriesDataValues);
    return TrendDataValues(dayItems.map((v) => v.trendDataValue).toList());
  }
}

class _DayItem {
  final DateTime dateTime;
  double value = 0;

  _DayItem(this.dateTime);

  void addValue(double add) {
    value += add;
  }

  TrendDataValue get trendDataValue {
    return TrendDataValue(dateTime.millisecondsSinceEpoch.toDouble(), value);
  }

  static List<_DayItem> buildDayItems(List<SeriesDataValue> seriesDataValues) {
    List<_DayItem> list = [];

    _DayItem? actItem;
    DateTime? actDay;

    _DayItem createDayItem(DateTime dateTimeDayStart) {
      _DayItem dayItem = _DayItem(dateTimeDayStart);
      list.add(dayItem);
      return dayItem;
    }

    for (var item in seriesDataValues) {
      DateTime dateDay = DateTimeUtils.truncateToDay(item.dateTime);
      actDay ??= dateDay;
      actItem ??= createDayItem(dateDay);

      // not matching date - create (empty)
      while (actDay!.isBefore(dateDay)) {
        actDay = DateTimeUtils.dayAfter(actDay);
        actItem = createDayItem(actDay);
      }

      actItem!.addValue(1);
    }

    return list;
  }
}
