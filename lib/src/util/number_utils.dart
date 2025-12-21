import 'package:intl/intl.dart';

class NumberUtils {
  /// format double value in active locale
  static String formatNumber(double value) {
    final locale = Intl.getCurrentLocale();

    final format = NumberFormat.decimalPattern(locale)
      ..turnOffGrouping()
      ..maximumFractionDigits = 6; // if required this could be a setting per series

    return format.format(value);
  }

  /// parse double value in active locale
  static double? tryParse(String value) {
    var nf = NumberFormat();
    return nf.tryParse(value)?.toDouble();
  }

  /// to string of number
  /// if double but no decimals print as int
  static String numToShortString(num num) {
    if (num is int) return num.toString();
    return num % 1 == 0 ? num.toInt().toString() : num.toString();
  }
}
