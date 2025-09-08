import '../../model/series/data/datetime_item.dart';
import '../date_time_utils.dart';

class DayItem<T extends DateTimeItem> {
  final List<T> dateTimeItems = [];
  late final DateTime day;

  DayItem(DateTime dateTime) {
    day = DateTimeUtils.truncateToDay(dateTime);
  }

  /// combines a list of DayTimeItems to a list of DayItems (one for each day) which contain the originals in their internal list.
  static List<I> buildDayItems<I extends DayItem, T extends DateTimeItem>(List<T> values, I Function(DateTime day) dayItemBuilder) {
    List<I> list = [];

    I? actItem;
    DateTime? actDay;

    I createDayItem(DateTime dateTimeDayStart) {
      I dayItem = dayItemBuilder(dateTimeDayStart);
      list.add(dayItem);
      return dayItem;
    }

    for (var item in values) {
      DateTime dateDay = DateTimeUtils.truncateToDay(item.datetime);
      actDay ??= dateDay;

      actItem ??= createDayItem(dateDay);

      // not matching date - create (empty)
      while (actDay!.isBefore(dateDay)) {
        actDay = DateTimeUtils.dayAfter(actDay);
        actItem = createDayItem(actDay);
      }

      actItem!.dateTimeItems.add(item);
    }

    return list;
  }
}
