import '../../model/series/data/datetime_item.dart';
import '../date_time_utils.dart';

/// DayItem which combines one or more DateTimeItems of the same date. E.g. as one combined value in a daily grid.
class DayItem<T extends DateTimeItem> {
  final List<T> dateTimeItems = [];

  /// Start of the day date time
  late final DateTime dayDate;

  DayItem(DateTime dateTime) {
    dayDate = DateTimeUtils.truncateToDay(dateTime);
  }

  void addItem(T item) {
    dateTimeItems.add(item);
  }

  /// returns the number of dateTimeItems
  int get count {
    return dateTimeItems.length;
  }

  DateTime get minDateTime {
    var c = count;
    if (c == 0) return dayDate;
    if (c == 1) return dateTimeItems.first.datetime;

    var d1 = dateTimeItems.first.datetime;
    var d2 = dateTimeItems.last.datetime;
    return (d1.isBefore(d2)) ? d1 : d2;
  }

  DateTime get maxDateTime {
    var c = count;
    if (c == 0) return dayDate;
    if (c == 1) return dateTimeItems.first.datetime;
     
    var d1 = dateTimeItems.first.datetime;
    var d2 = dateTimeItems.last.datetime;
    return (d1.isBefore(d2)) ? d1 : d2;
  }

  /// combines a list of DayTimeItems to a list of DayItems (one for each day) which contain the originals in their internal list.
  /// - [reversed] if true the returned list is in reverse order
  static List<I> buildDayItems<I extends DayItem, T extends DateTimeItem>(
    List<T> values,
    I Function(DateTime day) dayItemBuilder, {
    bool reversed = false,
    bool includeToday = false,
  }) {
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

    if (includeToday) {
      DateTime dateDay = DateTimeUtils.truncateToDay(DateTime.now());
      actDay ??= dateDay;
      actItem ??= createDayItem(dateDay);

      // not matching date - create (empty)
      while (actDay!.isBefore(dateDay)) {
        actDay = DateTimeUtils.dayAfter(actDay);
        actItem = createDayItem(actDay);
      }
    }

    if (reversed) {
      return list.reversed.toList();
    }

    return list;
  }
}
