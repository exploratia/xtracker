import 'package:flutter/material.dart';

import '../../../../util/color_utils.dart';
import '../series_data_value.dart';

class BloodPressureValue extends SeriesDataValue {
  final int high;
  final int low;

  BloodPressureValue(super.uuid, super.dateTime, this.high, this.low);

  BloodPressureValue cloneWith(DateTime dateTime, int high, int low) {
    return BloodPressureValue(uuid, dateTime, high, low);
  }

  static Color bestPossibleValueColor = const Color.fromRGBO(0, 160, 0, 1);

  static Color colorHigh(int value) {
    return ColorUtils.hue(bestPossibleValueColor, (120.0 - value) * 3);
  }

  static Color colorHighOf(BloodPressureValue bloodPressureValue) {
    return colorHigh(bloodPressureValue.high);
  }

  static Color colorLow(int value) {
    return ColorUtils.hue(bestPossibleValueColor, (80.0 - value) * 3);
  }

  static Color colorLowOf(BloodPressureValue bloodPressureValue) {
    return colorLow(bloodPressureValue.low);
  }
}
