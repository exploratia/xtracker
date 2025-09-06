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

  static String formateExportDateTime() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  /// format date yMd
  static String formateDate(DateTime dateTime) {
    return DateFormat.yMd().format(dateTime);
  }

  /// yyyy-MM-dd
  static String formateYYYMMDD(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String formateYear(DateTime dateTime) {
    return DateFormat.y().format(dateTime);
  }

  static String formateMonthYear(DateTime dateTime) {
    return DateFormat.yMMM().format(dateTime);
  }

  static String formateTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  static bool isMonthStart(DateTime dateTime) {
    return dateTime.day == 1;
  }

  static bool isMonthEnd(DateTime dateTime) {
    return dateTime.day == lastDayOfMonth(dateTime).day;
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

  static Color? backgroundColor(DateTime dateTime) {
    if (dateTime.weekday == DateTime.sunday) {
      return Globals.backgroundColorSunday;
    } else if (dateTime.weekday == DateTime.saturday) {
      return Globals.backgroundColorSaturday;
    }
    return null;
  }
}
