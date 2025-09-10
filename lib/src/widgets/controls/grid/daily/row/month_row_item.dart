import '../day/grid_day_item.dart';
import 'row_item.dart';

class MonthRowItem<T extends GridDayItem> extends RowItem<T> {
  MonthRowItem(DateTime dateTime, String? displayDate) : super(dateTime, displayDate, 31);
}
