import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/series/seriesItem/calculated/calculation_container.dart';
import 'package:xtracker/src/model/series/seriesItem/calculated/calculation_item_numeric.dart';
import 'package:xtracker/src/model/series/seriesItem/calculated/calculation_item_series_value.dart';
import 'package:xtracker/src/model/series/seriesItem/calculated/calculation_operator.dart';

void main() {
  group('CalcTest', () {
    test('test calc and serialize', () {
      var siid1 = "siid1";
      var siid2 = "siid2";

      Map<String, double> input = {
        siid1: 2,
        siid2: 3,
      };

      Map<String, double> previousInput = {};

      var calcContainer = CalculationContainer(sourceSiid: siid1, usePreviousInput: false, calculationItems: []);

      // add
      calcContainer.addCalculationItem(CalculationItemNumeric(value: 2, operator: CalculationOperator.add));

      double result = calcContainer.calculate(input, previousInput);
      expect(4, result);

      // mult
      calcContainer.addCalculationItem(CalculationItemNumeric(value: 5, operator: CalculationOperator.multiply));

      result = calcContainer.calculate(input, previousInput);
      expect(20, result);

      // div
      calcContainer.addCalculationItem(CalculationItemNumeric(value: 2, operator: CalculationOperator.divide));

      result = calcContainer.calculate(input, previousInput);
      expect(10, result);

      // sub
      calcContainer.addCalculationItem(CalculationItemNumeric(value: 3, operator: CalculationOperator.subtract));

      result = calcContainer.calculate(input, previousInput);
      expect(7, result);

      // sub other container
      var calcContainer2 = CalculationContainer(sourceSiid: siid2, usePreviousInput: false, calculationItems: []);
      calcContainer.addCalculationItem(CalculationItemSeriesValue(calculationContainer: calcContainer2, operator: CalculationOperator.subtract));

      result = calcContainer.calculate(input, previousInput);
      expect(4, result);

      // min
      calcContainer.addCalculationItem(CalculationItemSeriesValue(calculationContainer: calcContainer2, operator: CalculationOperator.min));

      result = calcContainer.calculate(input, previousInput);
      expect(3, result);

      // max
      calcContainer.addCalculationItem(CalculationItemNumeric(value: 5, operator: CalculationOperator.max));

      result = calcContainer.calculate(input, previousInput);
      expect(5, result);

      // serialize and deserialize and calc afterwards
      var serialized = jsonEncode(calcContainer.toJson());
      // print(serialized);
      expect(serialized.contains('{"operator":"*","inputType":"numeric","value":5.0}'), true);
      var deserialized = CalculationContainer.fromJson(jsonDecode(serialized));

      result = deserialized.calculate(input, previousInput);
      expect(5, result);
    });

    test('test div 0', () {
      var siid1 = "siid1";

      Map<String, double> input = {
        siid1: 2,
      };
      Map<String, double> previousInput = {};

      var calcContainer = CalculationContainer(sourceSiid: siid1, usePreviousInput: false, calculationItems: []);

      // div
      calcContainer.addCalculationItem(CalculationItemNumeric(value: 0, operator: CalculationOperator.divide));

      var result = calcContainer.calculate(input, previousInput);
      expect(result.isNaN, true);
    });

    test('test previous value', () {
      var siid1 = "siid1";

      Map<String, double> input = {
        siid1: 2,
      };
      Map<String, double> previousInput = {
        siid1: 3,
      };

      var calcContainer = CalculationContainer(sourceSiid: siid1, usePreviousInput: false, calculationItems: []);
      var calcContainer2 = CalculationContainer(sourceSiid: siid1, usePreviousInput: true, calculationItems: []);

      // min
      calcContainer.addCalculationItem(CalculationItemSeriesValue(calculationContainer: calcContainer2, operator: CalculationOperator.max));

      var result = calcContainer.calculate(input, previousInput);
      expect(result, 3);

      // serialize and deserialize and calc afterwards
      var serialized = jsonEncode(calcContainer.toJson());
      var deserialized = CalculationContainer.fromJson(jsonDecode(serialized));

      result = deserialized.calculate(input, previousInput);
      expect(3, result);
    });
  });
}
