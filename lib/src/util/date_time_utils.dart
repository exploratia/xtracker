import 'dart:math';
import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'globals.dart';

/// Date format pattern see: https://api.flutter.dev/flutter/intl/DateFormat-class.html
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
    final thisOrLastMonth = now.day > 15 ? now : DateTime(now.year, now.month, -1);
    return thisOrLastMonth;
  }

  static String formateDateT(DateTime dateTime, AppLocalizations t) {
    return DateFormat(t.patternDate).format(dateTime);
  }

  static String formateTimeT(DateTime dateTime, AppLocalizations t) {
    return DateFormat(t.patternTime).format(dateTime);
  }

  static String formateDateTimeT(DateTime dateTime, AppLocalizations t) {
    return DateFormat(t.patternDateTime).format(dateTime);
  }

  static String formateDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String formateMMMYYYY(DateTime dateTime) {
    return DateFormat("MMM yyyy").format(dateTime);
  }

  static String formateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formateDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  static bool isMonthStart(DateTime dateTime) {
    return dateTime.day == 1;
  }

  static bool isMonthEnd(DateTime dateTime) {
    return dateTime.day == lastDayOfMonth(dateTime).day;
  }

  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
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
