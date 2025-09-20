import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../../../../util/globals.dart';
import '../series_data_value.dart';

class DailyLifeValue extends SeriesDataValue {
  final String attributeUuid;

  DailyLifeValue(super.uuid, super.dateTime, this.attributeUuid);

  DailyLifeValue cloneWith(DateTime dateTime) {
    return DailyLifeValue(uuid, dateTime, attributeUuid);
  }

  factory DailyLifeValue.fromJson(Map<String, dynamic> json) => DailyLifeValue(
        json['uuid'] as String? ?? const Uuid().v4().toString(),
        DateTime.fromMillisecondsSinceEpoch(json['utcMs'] as int),
        json['attributeUuid'] as String? ?? Globals.invalid,
      );

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
        if (exportUuid) 'uuid': uuid,
        'utcMs': dateTime.millisecondsSinceEpoch,
        'attributeUuid': attributeUuid,
      };

  static DailyLifeValue checkOnDailyLifeValue(dynamic value) {
    if (value is DailyLifeValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$DailyLifeValue", got: "${value.runtimeType}"';
    throw Ex(errMsg);
  }
}
