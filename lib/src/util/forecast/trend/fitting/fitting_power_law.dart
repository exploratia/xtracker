import 'dart:math' as math;

import '../result/fit_result.dart';
import '../result/fit_result_power_law.dart';
import 'fitting.dart';

class FittingPowerLaw extends Fitting {
  FittingPowerLaw(super.trendDataValues);

  @override
  FitResult calc() {
    if (trendDataValues.values.length < 2) return FitResultPowerLaw(null, null, null);

    int n = 0;
    double sumLnxLny = 0;
    double sumLnx = 0;
    double sumLny = 0;
    double sumLnx2 = 0;

    for (var v in trendDataValues.trendCalculationDataProvider) {
      var xVal = v.x;
      var yVal = v.y;
      var lnX = math.log(xVal);
      var lnY = math.log(yVal);

      sumLnxLny += lnX * lnY;
      sumLnx += lnX;
      sumLny += lnY;
      sumLnx2 += lnX * lnX;
      n++;
    }

    double? a;
    double? b;
    if (n > 0) {
      b = (n * sumLnxLny - sumLnx * sumLny) / (n * sumLnx2 - sumLnx * sumLnx);
      a = (sumLny - b * sumLnx) / (n);
      a = math.exp(a);
    }

    return FitResultPowerLaw(a, b, trendDataValues.xOrigin);
  }
}
