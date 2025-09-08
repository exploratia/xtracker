import 'trend_data_value.dart';

class TrendDataValueNum extends TrendDataValue<num> {
  TrendDataValueNum(super.x, super.y);

  @override
  double get xVal => x.toDouble();
}
