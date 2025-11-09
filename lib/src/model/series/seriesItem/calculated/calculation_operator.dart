import 'dart:math' as math;

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
