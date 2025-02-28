import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'globals.dart';

/// Date format pattern see: https://api.flutter.dev/flutter/intl/DateFormat-class.html
class DateTimeUtils {
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
