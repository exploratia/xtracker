import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/forecast/trend/result/fit_result.dart';
import 'package:xtracker/src/util/forecast/trend/result/fit_result_linear.dart';
import 'package:xtracker/src/util/forecast/trend/trend_tendency.dart';

void main() {
  group('Fit result linear', () {
    test('test linear fit no gradient', () {
      FitResult fitResult;

      // special case no gradient
      fitResult = FitResultLinear(0, 1, 0);
      expect(true, fitResult.solvable);
      // on every x the same y value
      expect(1, fitResult.calc(1));
      expect(1, fitResult.calc(2));
      expect(TrendTendency.up, fitResult.getTendency());
      // backwards not unique or solvable
      expect(null, fitResult.calcX(1));
      expect(null, fitResult.calcX(2));
    });
    test('test linear fit simple values', () {
      FitResult fitResult;

      // simple
      fitResult = FitResultLinear(1, 0, 0);
      expect(true, fitResult.solvable);
      expect(1, fitResult.calc(1));
      expect(2, fitResult.calc(2));
      expect(TrendTendency.up, fitResult.getTendency());
      expect(1, fitResult.calcX(1));
      expect(2, fitResult.calcX(2));
      expect("y = 1.0 * x + 0.0", fitResult.formula());

      fitResult = FitResultLinear(1, 1, 0);
      expect(true, fitResult.solvable);
      expect(2, fitResult.calc(1));
      expect(3, fitResult.calc(2));
      expect(TrendTendency.up, fitResult.getTendency());
      expect(0, fitResult.calcX(1));
      expect(1, fitResult.calcX(2));
      expect("y = 1.0 * x + 1.0", fitResult.formula());

      fitResult = FitResultLinear(1, 1, 1);
      expect(true, fitResult.solvable);
      expect(1, fitResult.calc(1));
      expect(2, fitResult.calc(2));
      expect(TrendTendency.up, fitResult.getTendency());
      expect(1, fitResult.calcX(1));
      expect(2, fitResult.calcX(2));
      expect("y = 1.0 * (x - 1.0) + 1.0", fitResult.formula());
    });
    test('test linear fit negative gradient', () {
      FitResult fitResult;

      // negative gradient
      fitResult = FitResultLinear(-1, 0, 0);
      expect(true, fitResult.solvable);
      expect(-1, fitResult.calc(1));
      expect(-2, fitResult.calc(2));
      expect(TrendTendency.down, fitResult.getTendency());
      expect(-1, fitResult.calcX(1));
      expect(-2, fitResult.calcX(2));
      expect("y = -1.0 * x + 0.0", fitResult.formula());
    });
    test('test linear fit double values', () {
      FitResult fitResult;

      // non int values
      fitResult = FitResultLinear(1.23, 4.56, 7.89);
      expect(true, fitResult.solvable);
      expect(1208.8653, fitResult.calc(987));
      expect(TrendTendency.up, fitResult.getTendency());
      expect(535.89, fitResult.calcX(654));
    });
  });
}
