import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../../../../util/json_reader.dart';
import '../../series_def.dart';
import '../custom/custom_value.dart';

class MonthlyValue extends CustomValue {
  MonthlyValue(super.uuid, super.dateTime, super.values, super.aid);

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
      json.asStringOrNull("aid"),
    );
  }

  factory MonthlyValue.fromCSVList(List<dynamic> csv, SeriesDef seriesDef) {
    Map<String, double> values = {};
    int idx = 0;
    for (var seriesItem in seriesDef.seriesItems) {
      idx++;
      if (csv.length > idx) {
        var val = csv[idx];
        if (val is double) {
          values[seriesItem.siid] = val;
        } else if (val is int) {
          values[seriesItem.siid] = val.toDouble();
        }
      }
    }

    String? aid;
    {
      // build resolver map
      var attributes = seriesDef.customAttributesSettingsReadonly().attributes;
      Map<String, String> attributeName2Aid = {};
      for (var attribute in attributes) {
        attributeName2Aid[attribute.name] = attribute.aid;
      }
      idx++;
      aid = attributeName2Aid[csv[idx]];
    }

    return MonthlyValue(
      const Uuid().v4().toString(),
      DateTime.fromMillisecondsSinceEpoch(csv[0] as int),
      values,
      aid,
    );
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
