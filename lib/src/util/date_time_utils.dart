import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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

  static String formateTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formateDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
}
