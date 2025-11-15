import '../../../../util/json_reader.dart';
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
      val = item.calculate(val, input, previousInput);
    }
    return val;
  }

  factory CalculationContainer.fromJson(JsonReader json) {
    List<CalculationItem> calculationItems = [];

    for (var j in json.at('calculationItems').asReaders()) {
      var inputType = CalculationItem.inputTypeFromJson(j);
      switch (inputType) {
        case CalculationInputType.numeric:
          calculationItems.add(CalculationItemNumeric.fromJson(j));
        case CalculationInputType.seriesValue:
          calculationItems.add(CalculationItemSeriesValue.fromJson(j));
      }
    }

    return CalculationContainer(
      sourceSiid: json.at('sourceSiid').getString(),
      usePreviousInput: json.atOrNull('usePreviousInput')?.getBool() ?? false,
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
