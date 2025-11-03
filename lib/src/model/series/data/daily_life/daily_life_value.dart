import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../../../../util/globals.dart';
import '../../series_def.dart';
import '../series_data_value.dart';

class DailyLifeValue extends SeriesDataValue {
  final String aid;

  /// [aid] attribute unique id
  DailyLifeValue(super.uuid, super.dateTime, this.aid);

  DailyLifeValue cloneWith(DateTime dateTime) {
    return DailyLifeValue(uuid, dateTime, aid);
  }

  factory DailyLifeValue.fromJson(Map<String, dynamic> json) => DailyLifeValue(
        json['uuid'] as String? ?? const Uuid().v4().toString(),
        DateTime.fromMillisecondsSinceEpoch(json['utcMs'] as int),
        json['aid'] as String? ?? Globals.invalid,
      );

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
        if (exportUuid) 'uuid': uuid,
        'utcMs': dateTime.millisecondsSinceEpoch,
        'aid': aid,
      };

  @override
  List<dynamic> toCSVList(SeriesDef seriesDef) {
    var attributes = seriesDef.dailyLifeAttributesSettingsReadonly().attributes;
    for (var attribute in attributes) {
      if (attribute.aid == aid) return [dateTime.millisecondsSinceEpoch, attribute.name];
    }
    return [];
  }

  factory DailyLifeValue.fromCSVList(List<dynamic> csv, Map<String, String> attributeName2Aid) {
    return DailyLifeValue(
      const Uuid().v4().toString(),
      DateTime.fromMillisecondsSinceEpoch(csv[0] as int),
      attributeName2Aid[csv[1]] ?? Globals.invalid,
    );
  }

  static DailyLifeValue checkOnDailyLifeValue(dynamic value) {
    if (value is DailyLifeValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$DailyLifeValue", got: "${value.runtimeType}"';
    throw Ex(errMsg);
  }
}
