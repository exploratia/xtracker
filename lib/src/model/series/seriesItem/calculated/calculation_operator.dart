import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../util/ex.dart';
import '../../../../util/number_utils.dart';

enum CalculationOperator {
  add('+'),
  subtract('-'),
  multiply('*'),
  divide(':'),
  min('min'),
  max('max'),
  nan('NaN'),
  roundDecimals("≈d"),
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
      CalculationOperator.nan => LocaleKeys.enum_operator_nan_longNameInBrackets.tr(),
      CalculationOperator.roundDecimals => LocaleKeys.enum_operator_roundDecimals_longNameInBrackets.tr(),
    };
  }

  factory CalculationOperator.byDisplayName(String displayName) => CalculationOperator.values.firstWhere(
    (element) => element.displayName == displayName,
    orElse: () => throw Ex("'$displayName' is no valid calculation operator!"),
  );

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
      case nan:
        return a.isNaN ? b : a;
      case roundDecimals:
        if (a.isNaN || b.isNaN) return double.nan;
        if (b < 1) return a.roundToDouble();
        return NumberUtils.roundToDecimals(a, b.toInt());
    }
  }
}
