import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../../../../util/globals.dart';
import '../../../../util/json_reader.dart';
import '../../series_def.dart';
import '../series_data_value.dart';

class DailyLifeValue extends SeriesDataValue {
  final String tagId;

  /// [tagId] tag unique id
  DailyLifeValue(super.uuid, super.dateTime, this.tagId);

  DailyLifeValue cloneWith(DateTime dateTime) {
    return DailyLifeValue(uuid, dateTime, tagId);
  }

  factory DailyLifeValue.fromJson(JsonReader json) => DailyLifeValue(
    json.asStringOr('uuid', const Uuid().v4()),
    DateTime.fromMillisecondsSinceEpoch(json.asReader('utcMs').getInt()),
    json.asStringOr('tagId', Globals.invalid),
  );

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
    if (exportUuid) 'uuid': uuid,
    'utcMs': dateTime.millisecondsSinceEpoch,
    'tagId': tagId,
  };

  @override
  List<dynamic> toCSVList(SeriesDef seriesDef) {
    var tags = seriesDef.dailyLifeTagsSettingsReadonly().tags;
    for (var tag in tags) {
      if (tag.tagId == tagId) return [dateTime.millisecondsSinceEpoch, tag.name];
    }
    return [];
  }

  factory DailyLifeValue.fromCSVList(List<dynamic> csv, Map<String, String> tagName2TagId) {
    return DailyLifeValue(
      const Uuid().v4().toString(),
      DateTime.fromMillisecondsSinceEpoch(csv[0] as int),
      tagName2TagId[csv[1]] ?? Globals.invalid,
    );
  }

  static DailyLifeValue checkOnDailyLifeValue(dynamic value) {
    if (value is DailyLifeValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$DailyLifeValue", got: "${value.runtimeType}"';
    throw Ex(errMsg);
  }
}
