import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../../../../util/json_reader.dart';
import '../../series_def.dart';
import '../series_data_value.dart';

class DailyCheckValue extends SeriesDataValue {
  // no own members

  DailyCheckValue(super.uuid, super.dateTime);

  DailyCheckValue cloneWith(DateTime dateTime) {
    return DailyCheckValue(uuid, dateTime);
  }

  factory DailyCheckValue.fromJson(JsonReader json) => DailyCheckValue(
        json.atAsStringOr('uuid', const Uuid().v4()),
        DateTime.fromMillisecondsSinceEpoch(json.at('utcMs').getInt()),
      );

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
        if (exportUuid) 'uuid': uuid,
        'utcMs': dateTime.millisecondsSinceEpoch,
      };

  factory DailyCheckValue.fromCSVList(List<dynamic> csv) => DailyCheckValue(
        const Uuid().v4().toString(),
        DateTime.fromMillisecondsSinceEpoch(csv[0] as int),
      );

  @override
  List<dynamic> toCSVList(SeriesDef seriesDef) {
    return [dateTime.millisecondsSinceEpoch];
  }

  static DailyCheckValue checkOnDailyCheckValue(dynamic value) {
    if (value is DailyCheckValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$DailyCheckValue", got: "${value.runtimeType}"';
    throw Ex(errMsg);
  }
}
