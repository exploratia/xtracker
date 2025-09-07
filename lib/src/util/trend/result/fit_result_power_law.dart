import '../trend_tendency.dart';
import 'fit_result.dart';

class FitResultPowerLaw extends FitResult {
  FitResultPowerLaw(super.a, super.b, super.xOrigin);

  /// y = a*x + b
  @override
  double? calc(double x) {
    if (!solvable) return null;
    double result = a! * (x - xOrigin!) + b!;
    return result;
  }

  /// x = (a*xOrigin-b+y)/a
  @override
  double? calcX(double yValue) {
    if (!solvable) return null;
    //special case a==0 -> no gradient
    if (a == 0) {
      return null;
    }

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
