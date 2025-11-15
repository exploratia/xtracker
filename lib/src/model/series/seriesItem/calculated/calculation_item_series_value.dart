import '../../../../util/json_reader.dart';
import 'calculation_container.dart';
import 'calculation_input_type.dart';
import 'calculation_item.dart';
import 'calculation_operator.dart';

class CalculationItemSeriesValue extends CalculationItem {
  final CalculationContainer calculationContainer;

  CalculationItemSeriesValue({
    required this.calculationContainer,
    required super.operator,
  }) : super(
          inputType: CalculationInputType.seriesValue,
        );

  @override
  double calculate(double val, Map<String, double> input, Map<String, double> previousInput) {
    return operator.calc(val, calculationContainer.calculate(input, previousInput));
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['seriesValue'] = calculationContainer.toJson();
    return json;
  }

  factory CalculationItemSeriesValue.fromJson(JsonReader json) {
    CalculationOperator operator;
    var jInputType = json.at('operator');
    try {
      operator = CalculationOperator.byDisplayName(jInputType.getString());
    } catch (err) {
      throw JsonParseException('Invalid value at ${jInputType.pathString} - $err');
    }

    return CalculationItemSeriesValue(
      operator: operator,
      calculationContainer: CalculationContainer.fromJson(json.at('seriesValue')),
    );
  }
}
