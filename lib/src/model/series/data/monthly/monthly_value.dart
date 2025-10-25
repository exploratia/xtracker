import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../custom/custom_value.dart';

class MonthlyValue extends CustomValue {
  MonthlyValue(super.uuid, super.dateTime, super.values);

  factory MonthlyValue.fromJson(Map<String, dynamic> json) => MonthlyValue(
        json['uuid'] as String? ?? const Uuid().v4().toString(),
        DateTime.fromMillisecondsSinceEpoch(json['utcMs'] as int),
        json['values'] as Map<String, double>,
      );

  @override
  String toString() {
    return 'Monthly{...}';
  }

  static MonthlyValue checkOnMonthlyValue(dynamic value) {
    if (value is MonthlyValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$MonthlyValue", got: "${value.runtimeType}"';
    throw Ex(errMsg);
  }
}
