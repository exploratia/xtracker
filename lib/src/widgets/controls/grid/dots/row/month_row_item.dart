import '../day/day_item.dart';
import 'row_item.dart';

class MonthRowItem<T extends DayItem> extends RowItem<T> {
  MonthRowItem(DateTime dateTime, String? displayDate) : super(dateTime, displayDate, 31);
}
