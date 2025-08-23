import '../day/day_item.dart';
import 'row_item.dart';

class WeekRowItem<T extends DayItem> extends RowItem<T> {
  WeekRowItem(DateTime dateTime, String? displayDate) : super(dateTime, displayDate, 7);
}
