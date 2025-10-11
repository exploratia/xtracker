import '../../date_time_utils.dart';
import 'trend_data_value_datetime.dart';
import 'trend_data_values.dart';

class TrendDataValuesDateTime extends TrendDataValues<TrendDataValueDateTime> {
  TrendDataValuesDateTime(super.values);

  /// including today
  TrendDataValuesDateTime filterLastXDays(int days) {
    var dateFilter = DateTimeBuilder.now().truncateToMidDay.subtract(Duration(days: days + 1)).endOfDay.dateTime;
    return TrendDataValuesDateTime(values.where((v) => v.x.isAfter(dateFilter)).toList());
  }
}
