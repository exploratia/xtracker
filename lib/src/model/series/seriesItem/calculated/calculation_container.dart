import '../../../../util/logging/flutter_simple_logging.dart';
import 'calculation_input_type.dart';
import 'calculation_item.dart';
import 'calculation_item_numeric.dart';
import 'calculation_item_series_value.dart';

class CalculationContainer {
  final String sourceSiid;
  final bool usePreviousInput;
  final List<CalculationItem> calculationItems;

  /// -[sourceSiid] series item to get the start value from
  /// -[usePreviousInput] use previous value for calculation
  CalculationContainer({
    required this.sourceSiid,
    required this.calculationItems,
    required this.usePreviousInput,
  });

  CalculationContainer addCalculationItem(CalculationItem item) {
    calculationItems.add(item);
    return this;
  }

  /// check recursive if the given series item id is contained
  bool containsSeriesItem(String siid) {
    if (sourceSiid == siid) return true;
    for (var item in calculationItems) {
      if (item is CalculationItemSeriesValue) {
        if (item.calculationContainer.containsSeriesItem(siid)) return true;
      }
    }
    return false;
  }

  double calculate(Map<String, double> input, Map<String, double> previousInput) {
    // double? checkValue = input[sourceSiid];
    // if (checkValue == null) {
    //   SimpleLogging.w("Calculation not possible! No value for series item '$sourceSiid'.");
    //   return 0;
    // }
    // double val = checkValue;
    double val = (usePreviousInput ? previousInput : input)[sourceSiid] ?? double.nan;
    for (var item in calculationItems) {
      if (val.isNaN) return val;
      val = item.calculate(val, input, previousInput);
    }
    return val;
  }

  factory CalculationContainer.fromJson(Map<String, dynamic> json) {
    List<CalculationItem> calculationItems = [];
    List<dynamic> calculationItemsJson = json['calculationItems'] as List;

    for (var j in calculationItemsJson) {
      if (j is Map<String, dynamic>) {
        var inputType = CalculationItem.inputTypeFromJson(j);
        switch (inputType) {
          case CalculationInputType.numeric:
            calculationItems.add(CalculationItemNumeric.fromJson(j));
          case CalculationInputType.seriesValue:
            calculationItems.add(CalculationItemSeriesValue.fromJson(j));
        }
      } else {
        SimpleLogging.w("Unexpected element in calculationItems.");
      }
    }

    return CalculationContainer(
      sourceSiid: json['sourceSiid'] as String,
      usePreviousInput: json['usePreviousInput'] as bool? ?? false,
      calculationItems: calculationItems,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'sourceSiid': sourceSiid,
      'calculationItems': calculationItems
          .map(
            (e) => e.toJson(),
          )
          .toList(),
    };
    if (usePreviousInput) json['usePreviousInput'] = true;

    return json;
  }
}
