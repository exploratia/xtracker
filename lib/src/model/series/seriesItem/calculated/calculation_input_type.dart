enum CalculationInputType {
  numeric,
  seriesValue,
  ;

  static CalculationInputType fromName(String name) {
    return CalculationInputType.values.firstWhere((element) => element.name == name);
  }
}
