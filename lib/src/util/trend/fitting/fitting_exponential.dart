import 'dart:math' as math;

import '../result/fit_result.dart';
import '../result/fit_result_exponential.dart';
import 'fitting.dart';

class FittingExponential extends Fitting {
  FittingExponential(super.trendDataValues);

  @override
  FitResult calc() {
    if (trendDataValues.values.length < 2) return FitResultExponential(null, null, null);

    int n = 0;
    double sumLny = 0;
    double sumX2 = 0;
    double sumX = 0;
    double sumXLny = 0;

    for (var v in trendDataValues.trendCalculationDataProvider) {
      var xVal = v.x;
      var yVal = v.y;
      var lnY = math.log(yVal);

      sumLny += lnY;
      sumX2 += xVal * xVal;
      sumX += xVal;
      sumXLny += xVal * lnY;
      n++;
    }

    double? a;
    double? b;
    if (n > 0) {
      a = (sumLny * sumX2 - sumX * sumXLny) / (n * sumX2 - sumX * sumX);
      b = (n * sumXLny - sumX * sumLny) / (n * sumX2 - sumX * sumX);
      a = math.exp(a);
    }

    return FitResultExponential(a, b, trendDataValues.xOrigin);
  }
}
