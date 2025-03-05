class ChartMetaData {
  double xMin = double.maxFinite;
  double xMax = (double.maxFinite - 1) * -1;
  double yMin = double.maxFinite;
  double yMax = (double.maxFinite - 1) * -1;

  double _xPadding = 0;
  double _yPadding = 0;

  /// Jahres-Werte?
  bool yearly = false;
  bool showYearOnJan = true;

  bool showDots = false;

  void evaluateMetaDataSingleValue(num xVal, num yVal) {
    evaluateMetaData(xVal, [yVal]);
  }

  void evaluateMetaData(num xVal, List<num> yValues) {
    if (xVal < xMin) xMin = xVal.toDouble();
    if (xVal > xMax) xMax = xVal.toDouble();
    for (var yVal in yValues) {
      if (yVal < yMin) yMin = yVal.toDouble();
      if (yVal > yMax) yMax = yVal.toDouble();
    }
  }

  void calcPadding() {
    _xPadding = (xMax - xMin).abs() / 20;
    _yPadding = (yMax - yMin).abs() / 10;
  }

  double get xMinPadded {
    return xMin - _xPadding;
  }

  double get xMaxPadded {
    return xMax + _xPadding;
  }

  double get yMinPadded {
    if (yMin >= 0 && yMin < _yPadding) return 0;
    return yMin - _yPadding;
  }

  double get yMaxPadded {
    return yMax + _yPadding;
  }
}
