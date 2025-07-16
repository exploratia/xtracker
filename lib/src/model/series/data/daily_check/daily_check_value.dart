import 'package:uuid/uuid.dart';

import '../series_data_value.dart';

class DailyCheckValue extends SeriesDataValue {
  // no own members

  DailyCheckValue(super.uuid, super.dateTime);

  DailyCheckValue cloneWith(DateTime dateTime) {
    return DailyCheckValue(uuid, dateTime);
  }

  factory DailyCheckValue.fromJson(Map<String, dynamic> json) => DailyCheckValue(
        json['uuid'] as String? ?? const Uuid().v4().toString(),
        DateTime.fromMillisecondsSinceEpoch(json['utcMs'] as int),
      );

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
        if (exportUuid) 'uuid': uuid,
        'utcMs': dateTime.millisecondsSinceEpoch,
      };

  static DailyCheckValue checkOnDailyCheckValue(dynamic value) {
    if (value is DailyCheckValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$DailyCheckValue", got: "${value.runtimeType}"';
    throw Exception(errMsg);
  }
}
