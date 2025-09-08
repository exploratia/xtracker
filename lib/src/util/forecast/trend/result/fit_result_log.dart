import 'dart:math' as math;

import '../trend_tendency.dart';
import 'fit_result.dart';

/// power law trend analytics result
///
/// y = a * (x-xOrigin) ^ b
class FitResultLog extends FitResult {
  FitResultLog(super.a, super.b, super.xOrigin);

  @override
  double? calc(double x) {
    if (!solvable) return null;
    // y = a * (x-xOrigin) ^ b
    double result = a! * math.pow((x - xOrigin!), b!);
    return result;
  }

  @override
  double? calcX(double yValue) {
    if (!solvable) return null;
    //special case a==0 -> no gradient
    if (a == 0) {
      return null;
    }

    // x = ( y / a ) ^ ( 1 / b ) + xOrigin
    double result = math.pow((yValue / a!), (1 / b!)) + xOrigin!;
    return result;
  }

  @override
  String formula() {
    if (!solvable) return FitResult.formulaNotSolvable;
    return "y = $a * ${formulaX()} ^ b)";
  }

  @override
  TrendTendency getTendency() {
    TrendTendency result = solvable ? ((a! >= 0 && b! >= 0 || a! <= 0 && b! <= 0) ? TrendTendency.up : TrendTendency.down) : TrendTendency.none;
    return result;
  }
}
