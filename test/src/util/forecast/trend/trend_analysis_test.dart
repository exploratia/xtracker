import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/forecast/trend/result/fit_result.dart';
import 'package:xtracker/src/util/forecast/trend/trend_analytics.dart';
import 'package:xtracker/src/util/forecast/trend/trend_data_value_number.dart';
import 'package:xtracker/src/util/forecast/trend/trend_data_values.dart';

void main() {
  group('Fitting Linear', () {
    test('test linear fitting no or too little data', () async {
      List<TrendDataValueNum> values = [];
      FitResult fitResult = await TrendAnalytics.linear(TrendDataValues(values));
      expect(false, fitResult.solvable);

      values = [TrendDataValueNum(0, 0)];
      fitResult = await TrendAnalytics.linear(TrendDataValues(values));
      expect(false, fitResult.solvable);

      // 2x the same value
      values = [TrendDataValueNum(0, 0), TrendDataValueNum(0, 0)];
      fitResult = await TrendAnalytics.linear(TrendDataValues(values));
      expect(false, fitResult.solvable);
    });

    test('test linear fitting no gradient', () async {
      var values = [TrendDataValueNum(0, 0), TrendDataValueNum(1, 0)];
      FitResult fitResult = await TrendAnalytics.linear(TrendDataValues(values));

      expect(true, fitResult.solvable);
      expect(0, fitResult.a);
      expect(0, fitResult.b);
      expect(0, fitResult.xOrigin);
      expect("y = 0.0 * x + 0.0", fitResult.formula());
    });

    test('test linear fit simple values', () async {
      var values = [TrendDataValueNum(0, 0), TrendDataValueNum(1, 1)];
      FitResult fitResult = await TrendAnalytics.linear(TrendDataValues(values));
      expect(true, fitResult.solvable);
      expect(1, fitResult.a);
      expect(0, fitResult.b);
      expect(0, fitResult.xOrigin);
      expect("y = 1.0 * x + 0.0", fitResult.formula());

      values = [TrendDataValueNum(0, 1), TrendDataValueNum(1, 2)];
      fitResult = await TrendAnalytics.linear(TrendDataValues(values));
      expect(true, fitResult.solvable);
      expect(1, fitResult.a);
      expect(1, fitResult.b);
      expect(0, fitResult.xOrigin);
      expect("y = 1.0 * x + 1.0", fitResult.formula());

      values = [TrendDataValueNum(1, 0), TrendDataValueNum(2, 1)];
      fitResult = await TrendAnalytics.linear(TrendDataValues(values));
      expect(true, fitResult.solvable);
      expect(1, fitResult.a);
      expect(0, fitResult.b);
      expect(1, fitResult.xOrigin);
      expect("y = 1.0 * (x - 1.0) + 0.0", fitResult.formula());

      values = [TrendDataValueNum(2, 1), TrendDataValueNum(6, -1)];
      fitResult = await TrendAnalytics.linear(TrendDataValues(values));
      expect(true, fitResult.solvable);
      expect(-0.5, fitResult.a);
      expect(1, fitResult.b);
      expect(2, fitResult.xOrigin);
      expect("y = -0.5 * (x - 2.0) + 1.0", fitResult.formula());
    });
  });
}
