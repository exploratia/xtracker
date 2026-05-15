import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../../../../util/json_reader.dart';
import '../../series_def.dart';
import '../series_data_value.dart';

class HabitValue extends SeriesDataValue {
  // no own members

  HabitValue(super.uuid, super.dateTime);

  HabitValue cloneWith(DateTime dateTime) {
    return HabitValue(uuid, dateTime);
  }

  factory HabitValue.fromJson(JsonReader json) => HabitValue(
    json.asStringOr('uuid', const Uuid().v4()),
    DateTime.fromMillisecondsSinceEpoch(json.asReader('utcMs').getInt()),
  );

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
    if (exportUuid) 'uuid': uuid,
    'utcMs': dateTime.millisecondsSinceEpoch,
  };

  factory HabitValue.fromCSVList(List<dynamic> csv) => HabitValue(
    const Uuid().v4().toString(),
    DateTime.fromMillisecondsSinceEpoch(csv[0] as int),
  );

  @override
  List<dynamic> toCSVList(SeriesDef seriesDef) {
    return [dateTime.millisecondsSinceEpoch];
  }

  static HabitValue checkOnHabitValue(dynamic value) {
    if (value is HabitValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$HabitValue", got: "${value.runtimeType}"';
    throw Ex(errMsg);
  }
}
