import 'package:flutter/material.dart';

import '../../../../util/color_utils.dart';

class BloodPressureValue {
  final String uuid;

  final int high;
  final int low;

  BloodPressureValue(this.uuid, this.high, this.low);

  static Color bestPossibleValueColor = const Color.fromRGBO(0, 160, 0, 1);

  static Color colorHigh(int value) {
    return ColorUtils.hue(bestPossibleValueColor, (120.0 - value) * 3);
  }

  static Color colorLow(int value) {
    return ColorUtils.hue(bestPossibleValueColor, (80.0 - value) * 3);
  }
}
