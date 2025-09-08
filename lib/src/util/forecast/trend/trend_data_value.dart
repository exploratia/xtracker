abstract class TrendDataValue<X> {
  final X x;
  final double y;

  TrendDataValue(this.x, this.y);

  double get xVal;

  @override
  String toString() {
    return 'TrendDataValue{x: $x, y: $y}';
  }
}
