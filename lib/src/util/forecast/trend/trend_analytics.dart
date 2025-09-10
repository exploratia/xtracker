import 'dart:isolate';

import 'package:flutter/foundation.dart';

import 'fitting/fitting.dart';
import 'fitting/fitting_exponential.dart';
import 'fitting/fitting_linear.dart';
import 'fitting/fitting_log.dart';
import 'fitting/fitting_power_law.dart';
import 'result/fit_result.dart';
import 'trend_data_values.dart';

///
/// math functions http://www.mathe-fa.de/de
/// resolve equations http://www.mathe-paradies.de/mathe/gleichungsloeser/index.htm
/// http://www.zweigmedia.com/RealWorld/calctopic1/regression.html
/// http://mathworld.wolfram.com/LeastSquaresFitting.html
/// http://mathworld.wolfram.com/LeastSquaresFittingLogarithmic.html
/// http://mathworld.wolfram.com/LeastSquaresFittingExponential.html
/// http://mathworld.wolfram.com/LeastSquaresFittingPowerLaw.html
///
class TrendAnalytics {
  static Future<FitResult> linear(TrendDataValues trendDataValues) async {
    Fitting fitting = FittingLinear(trendDataValues);
    if (kIsWeb) {
      return fitting.calc();
    }
    return await Isolate.run(() => fitting.calc());
  }

  static Future<FitResult> exponential(TrendDataValues trendDataValues) async {
    Fitting fitting = FittingExponential(trendDataValues);
    if (kIsWeb) {
      return fitting.calc();
    }
    return await Isolate.run(() => fitting.calc());
  }

  static Future<FitResult> log(TrendDataValues trendDataValues) async {
    Fitting fitting = FittingLog(trendDataValues);
    if (kIsWeb) {
      return fitting.calc();
    }
    return await Isolate.run(() => fitting.calc());
  }

  static Future<FitResult> powerLaw(TrendDataValues trendDataValues) async {
    Fitting fitting = FittingPowerLaw(trendDataValues);
    if (kIsWeb) {
      return fitting.calc();
    }
    return await Isolate.run(() => fitting.calc());
  }
}
