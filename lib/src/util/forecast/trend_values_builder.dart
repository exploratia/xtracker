import '../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../model/series/data/daily_check/daily_check_value.dart';
import '../../model/series/data/habit/habit_value.dart';
import '../day_item/day_item.dart';
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
    var dayItems = DayItem.buildDayItems(seriesDataValues, (day) => DayItem(day));
    return TrendDataValuesDateTime(dayItems.map((di) => TrendDataValueDateTime(di.dayDate, di.count.toDouble())).toList());
  }

  static TrendDataValuesDateTime buildForHabit(List<HabitValue> seriesDataValues) {
    var dayItems = DayItem.buildDayItems(seriesDataValues, (day) => DayItem(day));
    return TrendDataValuesDateTime(dayItems.map((di) => TrendDataValueDateTime(di.dayDate, di.count.toDouble())).toList());
  }
}
