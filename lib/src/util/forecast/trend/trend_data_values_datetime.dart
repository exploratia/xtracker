import '../../date_time_utils.dart';
import 'trend_data_value_datetime.dart';
import 'trend_data_values.dart';

class TrendDataValuesDateTime extends TrendDataValues<TrendDataValueDateTime> {
  TrendDataValuesDateTime(super.values);

  /// including today
  TrendDataValuesDateTime filterLastXDays(int days) {
    var dateFilter = DateTimeUtils.truncateToDay(DateTimeUtils.truncateToDay(DateTime.now()).subtract(Duration(days: days - 1, microseconds: 1)));
    return TrendDataValuesDateTime(values.where((v) => v.x.isAfter(dateFilter)).toList());
  }
}
