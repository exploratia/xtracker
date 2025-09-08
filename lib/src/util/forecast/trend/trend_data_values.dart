import 'trend_data_value.dart';
import 'trend_data_value_number.dart';

class TrendDataValues<T extends TrendDataValue> {
  /// original values (not xOrigin adjusted)
  final List<T> values;
  late final double xOrigin;

  TrendDataValues(this.values) {
    xOrigin = values.isEmpty ? 0 : values.first.xVal;
  }

  int get length => values.length;

  /// returns x adjusted values for trend calculation
  Iterable<TrendDataValue> get trendCalculationDataProvider {
    return values.map((e) => TrendDataValueNum(e.xVal - xOrigin, e.y));
  }

  @override
  String toString() {
    return 'TrendDataValues{values: $values, xOrigin: $xOrigin}';
  }
}
