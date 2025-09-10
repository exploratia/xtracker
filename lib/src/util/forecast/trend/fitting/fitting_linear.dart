import '../result/fit_result.dart';
import '../result/fit_result_linear.dart';
import 'fitting.dart';

class FittingLinear extends Fitting {
  FittingLinear(super.trendDataValues);

  @override
  FitResult calc() {
    if (trendDataValues.length < 2) return FitResultLinear(null, null, null);

    int n = 0;
    double sumXY = 0;
    double sumX = 0;
    double sumY = 0;
    double sumX2 = 0;

    for (var v in trendDataValues.trendCalculationDataProvider) {
      var xVal = v.x;
      var yVal = v.y;

      sumXY += xVal * yVal;
      sumX += xVal;
      sumY += yVal;
      sumX2 += xVal * xVal;
      n++;
    }

    double? m;
    double? b;
    if (n > 0) {
      var divisor = (n * sumX2 - sumX * sumX);
      if (divisor == 0) {
        return FitResultLinear(null, null, null);
      }
      m = (n * sumXY - sumX * sumY) / divisor;
      b = (sumY - m * sumX) / n;
    }

    return FitResultLinear(m, b, trendDataValues.xOrigin);
  }
}
