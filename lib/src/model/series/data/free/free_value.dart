import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import 'multi_value.dart';

class FreeValue extends MultiValue {
  FreeValue(super.uuid, super.dateTime, super.values);

  factory FreeValue.fromJson(Map<String, dynamic> json) => FreeValue(
        json['uuid'] as String? ?? const Uuid().v4().toString(),
        DateTime.fromMillisecondsSinceEpoch(json['utcMs'] as int),
        json['values'] as Map<String, double>,
      );

  static FreeValue checkOnFreeValue(dynamic value) {
    if (value is FreeValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$FreeValue", got: "${value.runtimeType}"';
    throw Ex(errMsg);
  }
}
