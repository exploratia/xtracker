import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../../../../util/json_reader.dart';
import '../../series_def.dart';
import '../custom/custom_value.dart';

class MonthlyValue extends CustomValue {
  MonthlyValue(super.uuid, super.dateTime, super.values, super.tagId);

  factory MonthlyValue.fromJson(JsonReader json) {
    Map<String, double> values = {};
    var jValues = json.asReaderOrNull('values');
    if (jValues != null) {
      for (var entry in jValues.asMapReaders()) {
        values[entry.key] = entry.value.getDouble();
      }
    }
    return MonthlyValue(
      json.asStringOr('uuid', const Uuid().v4()),
      DateTime.fromMillisecondsSinceEpoch(json.asReader('utcMs').getInt()),
      values,
      json.asStringOrNull("tagId"),
    );
  }

  factory MonthlyValue.fromCSVList(List<dynamic> csv, SeriesDef seriesDef) {
    final value = CustomValue.fromCSVList(csv, seriesDef);
    return MonthlyValue(value.uuid, value.dateTime, value.values, value.tagId);
  }

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
