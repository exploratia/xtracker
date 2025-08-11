import 'package:uuid/uuid.dart';

import '../series_data_value.dart';

class HabitValue extends SeriesDataValue {
  // no own members

  HabitValue(super.uuid, super.dateTime);

  HabitValue cloneWith(DateTime dateTime) {
    return HabitValue(uuid, dateTime);
  }

  factory HabitValue.fromJson(Map<String, dynamic> json) => HabitValue(
        json['uuid'] as String? ?? const Uuid().v4().toString(),
        DateTime.fromMillisecondsSinceEpoch(json['utcMs'] as int),
      );

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
        if (exportUuid) 'uuid': uuid,
        'utcMs': dateTime.millisecondsSinceEpoch,
      };

  @override
  String toTooltip() {
    return '⬤';
  }

  static HabitValue checkOnHabitValue(dynamic value) {
    if (value is HabitValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$HabitValue", got: "${value.runtimeType}"';
    throw Exception(errMsg);
  }
}
