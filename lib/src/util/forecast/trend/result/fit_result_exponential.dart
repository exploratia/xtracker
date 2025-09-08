import 'dart:math' as math;

import '../trend_tendency.dart';
import 'fit_result.dart';

/// exponential trend analytics result
///
/// y = a * e ^ (b * (x - xOrigin))
class FitResultExponential extends FitResult {
  FitResultExponential(super.a, super.b, super.xOrigin);

  @override
  double? calc(double x) {
    if (!solvable) return null;
    // y = a * e ^ (b * (x - xOrigin))
    double result = a! * math.exp(b! * (x - xOrigin!));
    return result;
  }

  @override
  double? calcX(double yValue) {
    if (!solvable) return null;
    //special case a==0 || b==0 -> no gradient
    if (a == 0 || b == 0) {
      return null;
    }

    // x = (ln(y/a)+b*xOrigin)/b
    double result = (math.log(yValue / a!) + b! * xOrigin!) / b!;
    return result;
  }

  @override
  String formula() {
    if (!solvable) return FitResult.formulaNotSolvable;
    return "y = $a * e ^ ($b * ${formulaX()})";
  }

  @override
  TrendTendency getTendency() {
    TrendTendency result = solvable ? ((a! >= 0 && b! >= 0 || a! <= 0 && b! <= 0) ? TrendTendency.up : TrendTendency.down) : TrendTendency.none;
    return result;
  }
}
