import '../date_time_utils.dart';
import 'trend/result/fit_result.dart';

class Forecast {
  static List<DailyForecastValue> buildDailyForecastValues(FitResult fitResult, {int days = 7}) {
    List<DailyForecastValue> res = [];
    if (fitResult.solvable && days > 0) {
      var date = DateTimeUtils.truncateToDay(DateTime.now()); // today, but start with forecast tomorrow (each iteration increases the day)
      for (var i = 0; i < days; ++i) {
        date = DateTimeUtils.truncateToMidDay(DateTimeUtils.dayAfter(date));
        double? yVal = fitResult.calc(date.millisecondsSinceEpoch.toDouble());
        res.add(DailyForecastValue(date, yVal));
      }
    }
    return res;
  }
}

class DailyForecastValue {
  final DateTime date;
  final double? value;

  DailyForecastValue(this.date, this.value);

  @override
  String toString() {
    return 'DailyForecastValue{date: $date, value: $value}';
  }
}
