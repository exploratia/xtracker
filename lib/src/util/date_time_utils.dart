import 'dart:math';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';

import 'globals.dart';

/// Date format pattern see: https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
class DateTimeUtils {
  static Map<int, String> _month2ShortName = _createMonth2ShortNameMapping();

  static Map<int, String> _createMonth2ShortNameMapping() {
    Map<int, String> result = {};
    for (var i = 1; i <= 12; ++i) {
      result[i] = DateFormat.MMM().format(DateTime(2023, i));
    }
    // 0 == 12 damit einfach % gerechnet werden kann
    result[0] = DateFormat.MMM().format(DateTime(2023, 12));
    return Map.unmodifiable(result);
  }

  /// Has to be called once and on language change
  static void init() {
    _month2ShortName = _createMonth2ShortNameMapping();
  }

  static String getMonthShort(int month) {
    var m = min(12, max(0, month));
    return _month2ShortName[m] ?? 'Unset';
  }

  static DateTime getMonthlyDataInsertDate() {
    final now = DateTime.now();
    final thisOrLastMonth = now.day > 15 ? truncateToDay(now) : DateTime(now.year, now.month, -1);
    return thisOrLastMonth;
  }

  static String formatExportDateTime() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  /// format date yMd
  static String formatDate(DateTime dateTime) {
    return DateFormat.yMd().format(dateTime);
  }

  /// format date yMEd
  static String formatDateWithDay(DateTime dateTime) {
    return DateFormat.yMEd().format(dateTime);
  }

  /// yyyy-MM-dd
  static String formatYYYYMMDD(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String formatYear(DateTime dateTime) {
    return DateFormat.y().format(dateTime);
  }

  static String formatMonthYear(DateTime dateTime) {
    return DateFormat.yMMM().format(dateTime);
  }

  /// E - e.g. Mon
  static String formatShortDay(DateTime dateTime) {
    return DateFormat.E().format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  static bool isMonthStart(DateTime dateTime) {
    return dateTime.day == 1;
  }

  static bool isMonthEnd(DateTime dateTime) {
    return dateTime.day == lastDayOfMonth(dateTime).day;
  }

  // is it a day start at 00:00:00.000
  static bool isDayDate(DateTime dateTime) {
    return dateTime.isAtSameMomentAs(DateTime(dateTime.year, dateTime.month, dateTime.day));
  }

  static DateTime mondayOfSameWeek(DateTime date) {
    int daysToSubtract = date.weekday - DateTime.monday;
    DateTime monday = date.subtract(Duration(days: daysToSubtract));

    if (date.isUtc) {
      // Monday in UTC
      return DateTime.utc(monday.year, monday.month, monday.day);
    } else {
      // Monday in local time
      return DateTime(monday.year, monday.month, monday.day);
    }
  }

  static DateTime lastDayOfMonth(DateTime date) {
    return firstDayOfMonth(firstDayOfMonth(date).add(const Duration(days: 40))).subtract(const Duration(days: 1));
    // was not always correct: missing april - probably because of the 29th feb.
    // return DateTime(date.year, date.month + 1, 0);
  }

  static DateTime firstDayOfNextMonth(DateTime date) {
    return firstDayOfMonth(firstDayOfMonth(date).add(const Duration(days: 40)));
  }

  static DateTime firstDayOfPreviousMonth(DateTime date) {
    return firstDayOfMonth(firstDayOfMonth(date).subtract(const Duration(days: 10)));
  }

  /// first day of month 00:00:00.000
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// yyyy-01-01 00:00:00.000
  static DateTime firstDayOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime dayBefore(DateTime date) {
    // Because of time change (de:Zeitumstellung) subtract only half a day and then truncate to day start
    return truncateToDay(date.subtract(Duration(hours: date.hour + 12)));
  }

  static DateTime dayAfter(DateTime date) {
    return DateTimeUtils.truncateToDay(DateTimeUtils.truncateToDay(date).add(const Duration(hours: 36)));
  }

  static DateTime truncateToDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime truncateToMidDay(DateTime date) {
    return truncateToDay(date).add(const Duration(hours: 12));
  }

  /// end of day is next day start -1ys
  static DateTime endOfDay(DateTime date) {
    return dayAfter(date).subtract(const Duration(microseconds: 1));
  }

  /// returns the date with max utc timestamp
  static DateTime maxDate(DateTime date1, DateTime date2) {
    return (date1.isAfter(date2)) ? date1 : date2;
  }

  /// returns the date with min utc timestamp
  static DateTime minDate(DateTime date1, DateTime date2) {
    return (date1.isBefore(date2)) ? date1 : date2;
  }

  static int minutesOfDay(DateTime dateTime) {
    return dateTime.hour * 60 + dateTime.minute;
  }

  static Color? backgroundColor(DateTime dateTime) {
    if (dateTime.weekday == DateTime.sunday) {
      return Globals.backgroundColorSunday;
    } else if (dateTime.weekday == DateTime.saturday) {
      return Globals.backgroundColorSaturday;
    }
    return null;
  }
}

class DateTimeBuilder {
  late DateTime _dateTime;

  DateTimeBuilder(DateTime? dateTime) {
    _dateTime = dateTime ?? DateTime.now();
  }

  DateTimeBuilder.now() {
    _dateTime = DateTime.now();
  }

  DateTime get dateTime => _dateTime;

  DateTimeBuilder get clone => DateTimeBuilder(_dateTime);

  DateTimeBuilder get mondayOfSameWeek => DateTimeBuilder(DateTimeUtils.mondayOfSameWeek(_dateTime));

  DateTimeBuilder get lastDayOfMonth => DateTimeBuilder(DateTimeUtils.lastDayOfMonth(_dateTime));

  DateTimeBuilder get firstDayOfNextMonth => DateTimeBuilder(DateTimeUtils.firstDayOfNextMonth(_dateTime));

  DateTimeBuilder get firstDayOfPreviousMonth => DateTimeBuilder(DateTimeUtils.firstDayOfPreviousMonth(_dateTime));

  /// first day of month 00:00:00.000
  DateTimeBuilder get firstDayOfMonth => DateTimeBuilder(DateTimeUtils.firstDayOfMonth(_dateTime));

  /// yyyy-01-01 00:00:00.000
  DateTimeBuilder get firstDayOfYear => DateTimeBuilder(DateTimeUtils.firstDayOfYear(_dateTime));

  DateTimeBuilder get dayBefore => DateTimeBuilder(DateTimeUtils.dayBefore(_dateTime));

  DateTimeBuilder get dayAfter => DateTimeBuilder(DateTimeUtils.dayAfter(_dateTime));

  DateTimeBuilder get truncateToDay => DateTimeBuilder(DateTimeUtils.truncateToDay(_dateTime));

  DateTimeBuilder get truncateToMidDay => DateTimeBuilder(DateTimeUtils.truncateToMidDay(_dateTime));

  /// end of day is next day start -1ys
  DateTimeBuilder get endOfDay => DateTimeBuilder(DateTimeUtils.endOfDay(_dateTime));

  DateTimeBuilder subtract(Duration duration) => DateTimeBuilder(_dateTime.subtract(duration));

  DateTimeBuilder add(Duration duration) => DateTimeBuilder(_dateTime.add(duration));
}
