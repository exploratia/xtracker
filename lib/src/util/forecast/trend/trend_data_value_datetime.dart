import 'trend_data_value.dart';

class TrendDataValueDateTime extends TrendDataValue<DateTime> {
  TrendDataValueDateTime(super.x, super.y);

  @override
  double get xVal => x.millisecondsSinceEpoch.toDouble();
}
