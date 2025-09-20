import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../util/color_utils.dart';
import '../../../../util/ex.dart';
import '../series_data_value.dart';

class BloodPressureValue extends SeriesDataValue {
  static const int maxValue = 999;
  static const int minValue = 0;
  final int high;
  final int low;
  final bool medication;

  BloodPressureValue(super.uuid, super.dateTime, this.high, this.low, this.medication);

  factory BloodPressureValue.fromJson(Map<String, dynamic> json) => BloodPressureValue(
        json['uuid'] as String? ?? const Uuid().v4().toString(),
        DateTime.fromMillisecondsSinceEpoch(json['utcMs'] as int),
        json['high'] as int,
        json['low'] as int,
        json['medication'] as bool? ?? false,
      );

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
        if (exportUuid) 'uuid': uuid,
        'utcMs': dateTime.millisecondsSinceEpoch,
        'high': high,
        'low': low,
        if (medication) 'medication': medication, // only save if true
      };

  @override
  String toString() {
    return 'BloodPressureValue{high: $high, low: $low, medication: $medication}';
  }

  static Color bestPossibleValueColor = const Color.fromRGBO(0, 160, 0, 1);

  static Color colorHigh(int value) {
    int val = max(min(value, 160), 80); // 120 +- 40
    return ColorUtils.hue(bestPossibleValueColor, (120.0 - val) * 3);
  }

  static Color colorHighOf(BloodPressureValue bloodPressureValue) {
    return colorHigh(bloodPressureValue.high);
  }

  static Color colorLow(int value) {
    int val = max(min(value, 120), 40); // 80 +- 40
    return ColorUtils.hue(bestPossibleValueColor, (80.0 - val) * 3);
  }

  static Color colorLowOf(BloodPressureValue bloodPressureValue) {
    return colorLow(bloodPressureValue.low);
  }

  static BloodPressureValue checkOnBloodPressureValue(dynamic value) {
    if (value is BloodPressureValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$BloodPressureValue", got: "${value.runtimeType}"';
    throw Ex(errMsg);
  }
}
