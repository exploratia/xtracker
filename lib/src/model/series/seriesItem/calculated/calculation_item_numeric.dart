import '../../../../util/json_reader.dart';
import 'calculation_input_type.dart';
import 'calculation_item.dart';
import 'calculation_operator.dart';

class CalculationItemNumeric extends CalculationItem {
  final double value;

  CalculationItemNumeric({
    required this.value,
    required super.operator,
  }) : super(
         inputType: CalculationInputType.numeric,
       );

  @override
  double calculate(double val, Map<String, double> input, Map<String, double> previousInput) {
    return operator.calc(val, value);
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['value'] = value;
    return json;
  }

  factory CalculationItemNumeric.fromJson(JsonReader json) {
    CalculationOperator operator;
    var jInputType = json.asReader('operator');
    try {
      operator = CalculationOperator.byDisplayName(jInputType.getString());
    } catch (err) {
      throw JsonParseException('Invalid value at ${jInputType.pathString} - $err');
    }

    return CalculationItemNumeric(
      operator: operator,
      value: json.asReader('value').getDouble(),
    );
  }
}
