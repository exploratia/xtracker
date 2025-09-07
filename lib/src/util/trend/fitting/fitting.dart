import '../result/fit_result.dart';
import '../trend_data_values.dart';

abstract class Fitting {
  final TrendDataValues trendDataValues;

  Fitting(this.trendDataValues);

  FitResult calc();
}
