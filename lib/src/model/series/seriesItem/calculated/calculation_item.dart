import '../../../../util/json_reader.dart';
import 'calculation_input_type.dart';
import 'calculation_operator.dart';

abstract class CalculationItem {
  final CalculationOperator operator;
  final CalculationInputType inputType;

  CalculationItem({required this.operator, required this.inputType});

  double calculate(double val, Map<String, double> input, Map<String, double> previousInput);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'operator': operator.displayName,
      'inputType': inputType.name,
    };

    return json;
  }

  static CalculationInputType inputTypeFromJson(JsonReader json) {
    var jInputType = json.asReader('inputType');
    try {
      return CalculationInputType.byName(jInputType.getString());
    } catch (err) {
      throw JsonParseException('Invalid value at ${jInputType.pathString} - $err');
    }
  }
}
