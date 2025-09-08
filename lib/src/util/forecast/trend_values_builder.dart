import '../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../model/series/data/daily_check/daily_check_value.dart';
import '../../model/series/data/habit/habit_value.dart';
import '../../model/series/data/series_data_value.dart';
import '../date_time_utils.dart';
import '../pair.dart';
import 'trend/trend_data_value_datetime.dart';
import 'trend/trend_data_values_datetime.dart';

class TrendValuesBuilder {
  static Pair<TrendDataValuesDateTime, TrendDataValuesDateTime> buildForBloodPressure(List<BloodPressureValue> seriesDataValues) {
    List<TrendDataValueDateTime> high = [];
    List<TrendDataValueDateTime> low = [];
    for (var v in seriesDataValues) {
      high.add(TrendDataValueDateTime(v.dateTime, v.high.toDouble()));
      low.add(TrendDataValueDateTime(v.dateTime, v.low.toDouble()));
    }
    return Pair(TrendDataValuesDateTime(high), TrendDataValuesDateTime(low));
  }

  static TrendDataValuesDateTime buildForDailyCheck(List<DailyCheckValue> seriesDataValues) {
    var dayItems = _DayItem.buildDayItems(seriesDataValues);
    return TrendDataValuesDateTime(dayItems.map((v) => v.trendDataValue).toList());
  }

  static TrendDataValuesDateTime buildForHabit(List<HabitValue> seriesDataValues) {
    var dayItems = _DayItem.buildDayItems(seriesDataValues);
    return TrendDataValuesDateTime(dayItems.map((v) => v.trendDataValue).toList());
  }
}

class _DayItem {
  final DateTime dateTime;
  double value = 0;

  _DayItem(this.dateTime);

  void addValue(double add) {
    value += add;
  }

  TrendDataValueDateTime get trendDataValue {
    return TrendDataValueDateTime(dateTime, value);
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
