import '../trend_tendency.dart';

abstract class FitResult {
  static const String formulaNotSolvable = "[-]";

  /// coefficient A of trend function
  final double? a;

  /// coefficient B of trend function
  final double? b;

  /// returns x shift of trend function (time shift x=t)
  final double? xOrigin;

  /// trend solvable -> calculated formula
  /// <b>Attention</b> even if solvable - not every value must have a result
  late final bool solvable;

  FitResult(this.a, this.b, this.xOrigin) {
    solvable = a != null && b != null && xOrigin != null;
  }

  /// returns the formula for calculating prediction values as string
  String formula();

  /// returns x for formula string
  String formulaX() {
    String x = "x";
    if (xOrigin != null && xOrigin != 0) {
      x = "(x - $xOrigin)"; //shift x coordinate origin
    }
    return x;
  }

  /// calculate the predicted value for given x value (timestamp)
  /// returns predicted value or null if not solvable
  double? calc(double x);

  /// calculate the x value (timestamp) when the function reaches the given y value.
  /// returns x value or null if not solvable (or not unique)
  double? calcX(double yValue);

  /// return trend tendency (up, down) (none if not calculated)
  TrendTendency getTendency();
}
