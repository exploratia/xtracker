import '../../../../../util/date_time_utils.dart';
import '../day/day_item.dart';
import 'month_row_item.dart';
import 'week_row_item.dart';

abstract class RowItem<T extends DayItem> {
  final DateTime dateTime;
  String? displayDate;
  late final List<T?> dayItems;

  RowItem(this.dateTime, this.displayDate, int listSize) {
    dayItems = List<T?>.filled(listSize, null);
  }

  /// returns DayItem at given index or null
  T? getDayItem(int index) {
    if (index < 0 || index >= dayItems.length) return null;
    return dayItems[index];
  }

  static List<RowItem<T>> buildMonthRowItems<T extends DayItem>(List<T> dayItemsDescending) {
    List<RowItem<T>> list = [];

    RowItem<T>? actRowItem;
    DateTime? actFirstOfMonth;

    RowItem<T> createRowItem(DateTime dateTimeFirstOfMonth) {
      String? displayDate;
      if (dateTimeFirstOfMonth.month % 2 == 0) {
        displayDate = DateTimeUtils.formateMonthYear(dateTimeFirstOfMonth);
      }
      MonthRowItem<T> rowItem = MonthRowItem(dateTimeFirstOfMonth, displayDate);
      list.add(rowItem);
      return rowItem;
    }

    for (var dayItem in dayItemsDescending) {
      var firstOfMonth = DateTimeUtils.firstDayOfMonth(dayItem.dateTimeDayStart);
      actFirstOfMonth ??= firstOfMonth;

      // no act row yet - create the first row
      actRowItem ??= createRowItem(firstOfMonth);

      // not matching date - create (empty) rows (= empty month)
      while (actFirstOfMonth!.isAfter(firstOfMonth)) {
        actFirstOfMonth = DateTimeUtils.firstDayOfPreviousMonth(actFirstOfMonth);
        actRowItem = createRowItem(actFirstOfMonth);
      }

      // set dayItem at day position in dayItems
      actRowItem!.dayItems[dayItem.dateTimeDayStart.day - 1] = dayItem;
    }

    checkAtLeastOneDisplayDate(list);

    return list;
  }

  static List<RowItem<T>> buildWeekRowItems<T extends DayItem>(List<T> dayItemsDescending) {
    List<RowItem<T>> list = [];

    RowItem<T>? actRowItem;
    DateTime? actFirstOfWeek;

    RowItem<T> createRowItem(DateTime dateTimeFirstDayOfWeek) {
      var dateTimeLastDayOfWeek = dateTimeFirstDayOfWeek.add(const Duration(days: 6, hours: 12));
      bool weekContainsMonthStart = dateTimeFirstDayOfWeek.day == 1 || dateTimeFirstDayOfWeek.month != dateTimeLastDayOfWeek.month;

      String? displayDate;
      if (weekContainsMonthStart) {
        displayDate = DateTimeUtils.formateMonthYear(dateTimeLastDayOfWeek);
      }
      WeekRowItem<T> rowItem = WeekRowItem(dateTimeFirstDayOfWeek, displayDate);
      list.add(rowItem);
      return rowItem;
    }

    for (var dayItem in dayItemsDescending) {
      var firstOfWeek = DateTimeUtils.mondayOfSameWeek(dayItem.dateTimeDayStart);
      actFirstOfWeek ??= firstOfWeek;

      // no act row yet - create the first row
      actRowItem ??= createRowItem(firstOfWeek);

      // not matching date - create (empty) rows (= empty weeks - should not happen dayItems should have no holes)
      if (actFirstOfWeek.isAfter(firstOfWeek)) {
        actFirstOfWeek = firstOfWeek;
        actRowItem = createRowItem(actFirstOfWeek);
      }

      // set dayItem at day position in dayItems
      actRowItem.dayItems[dayItem.dateTimeDayStart.weekday - 1] = dayItem;
    }

    checkAtLeastOneDisplayDate(list);

    return list;
  }

  static void checkAtLeastOneDisplayDate<T extends DayItem>(List<RowItem<T>> list) {
    if (list.isNotEmpty && !list.fold(false, (previousValue, element) => previousValue || element.displayDate != null)) {
      list.last.displayDate = DateTimeUtils.formateMonthYear(list.last.dateTime);
    }
  }
}
