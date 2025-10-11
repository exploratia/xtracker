import '../analytics/analytics.dart';
import '../date_time_utils.dart';

class AfterDateFilter {
  late final DateTime filterDateTime;

  AfterDateFilter(this.filterDateTime);

  /// - [days] if <=0 no filter
  AfterDateFilter.daysBack(int days) {
    if (days <= Analytics.allDays) {
      filterDateTime = DateTime(0);
    } else {
      filterDateTime = DateTimeBuilder.now().truncateToMidDay.subtract(Duration(days: days + 1)).endOfDay.dateTime;
    }
  }

  bool filter(DateTime dateTime) {
    return dateTime.isAfter(filterDateTime);
  }
}
