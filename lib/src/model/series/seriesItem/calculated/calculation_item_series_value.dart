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

  factory CalculationItemSeriesValue.fromJson(Map<String, dynamic> json) => CalculationItemSeriesValue(
        operator: CalculationOperator.fromDisplayName(json['operator'] as String),
        calculationContainer: CalculationContainer.fromJson(json['seriesValue'] as Map<String, dynamic>),
      );
}
