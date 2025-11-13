import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';

import '../../../../../generated/locale_keys.g.dart';

enum CalculationOperator {
  add('+'),
  subtract('-'),
  multiply('*'),
  divide(':'),
  min('min'),
  max('max'),
  ;

  const CalculationOperator(this.displayName);

  final String displayName;

  static String toBracketDisplayString(CalculationOperator inputType) {
    return switch (inputType) {
      CalculationOperator.add => LocaleKeys.enum_operator_add_longNameInBrackets.tr(),
      CalculationOperator.subtract => LocaleKeys.enum_operator_subtract_longNameInBrackets.tr(),
      CalculationOperator.multiply => LocaleKeys.enum_operator_multiply_longNameInBrackets.tr(),
      CalculationOperator.divide => LocaleKeys.enum_operator_divide_longNameInBrackets.tr(),
      CalculationOperator.min => LocaleKeys.enum_operator_min_longNameInBrackets.tr(),
      CalculationOperator.max => LocaleKeys.enum_operator_max_longNameInBrackets.tr(),
    };
  }

  factory CalculationOperator.fromDisplayName(String displayName) => CalculationOperator.values.firstWhere((element) => element.displayName == displayName);

  double calc(double a, double b) {
    switch (this) {
      case add:
        return a + b;
      case subtract:
        return a - b;
      case multiply:
        return a * b;
      case divide:
        {
          if (b == 0) return double.nan;
          return a / b;
        }
      case min:
        return math.min(a, b);
      case max:
        return math.max(a, b);
    }
  }
}
