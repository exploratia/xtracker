import 'dart:math' as math;

import '../result/fit_result.dart';
import '../result/fit_result_log.dart';
import 'fitting.dart';

class FittingLog extends Fitting {
  FittingLog(super.trendDataValues);

  @override
  FitResult calc() {
    if (trendDataValues.values.length < 2) return FitResultLog(null, null, null);

    int n = 0;
    double sumYLnx = 0;
    double sumY = 0;
    double sumLnx = 0;
    double sumLnx2 = 0;

    for (var v in trendDataValues.trendCalculationDataProvider) {
      var xVal = v.x;
      var yVal = v.y;
      var lnX = math.log(xVal);

      sumYLnx += yVal * lnX;
      sumY += yVal;
      sumLnx += lnX;
      sumLnx2 += lnX * lnX;
      n++;
    }

    double? a;
    double? b;
    if (n > 0) {
      b = (n * sumYLnx - sumY * sumLnx) / (n * sumLnx2 - sumLnx * sumLnx);
      a = (sumY - b * sumLnx) / n;
    }

    return FitResultLog(a, b, trendDataValues.xOrigin);
  }
}
