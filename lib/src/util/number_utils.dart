import 'package:intl/intl.dart';

class NumberUtils {
  /// format double value in active locale
  static String formatNumber(double value) {
    var nf = NumberFormat();
    return nf.format(value);
  }
}
