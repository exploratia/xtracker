import '../trend_tendency.dart';
import 'fit_result.dart';

/// linear trend analytics result
///
/// y = a*x + b
///
/// y = a * (x - xOrigin) + b
class FitResultLinear extends FitResult {
  FitResultLinear(super.a, super.b, super.xOrigin);

  @override
  double? calc(double x) {
    if (!solvable) return null;
    // y = a*x + b
    double result = a! * (x - xOrigin!) + b!;
    return result;
  }

  @override
  double? calcX(double yValue) {
    if (!solvable) return null;
    //special case a==0 -> no gradient
    if (a == 0) {
      return null;
    }

    // x = (a*xOrigin-b+y)/a
    double result = (a! * xOrigin! - b! + yValue) / a!;
    return result;
  }

  @override
  String formula() {
    if (!solvable) return FitResult.formulaNotSolvable;
    if (b! < 0) {
      return "y = ${a!} * ${formulaX()} ${b!}"; // prevent +-
    }
    return "y = ${a!} * ${formulaX()} + ${b!}";
  }

  @override
  TrendTendency getTendency() {
    TrendTendency result = solvable ? (a! >= 0 ? TrendTendency.up : TrendTendency.down) : TrendTendency.none;
    return result;
  }
}
