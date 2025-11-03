import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../../series_def.dart';
import '../custom/custom_value.dart';

class MonthlyValue extends CustomValue {
  MonthlyValue(super.uuid, super.dateTime, super.values);

  factory MonthlyValue.fromJson(Map<String, dynamic> json) {
    Map<String, double> values = {};
    var jValues = json['values'] as Map?;
    if (jValues != null) {
      for (var entry in jValues.entries) {
        if (entry.key is String) {
          if (entry.value is double) {
            values[entry.key] = entry.value;
          } else if (entry.value is int) {
            int intVal = entry.value;
            values[entry.key] = intVal.toDouble();
          }
        }
      }
    }
    return MonthlyValue(
      json['uuid'] as String? ?? const Uuid().v4().toString(),
      DateTime.fromMillisecondsSinceEpoch(json['utcMs'] as int),
      values,
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
    return MonthlyValue(
      const Uuid().v4().toString(),
      DateTime.fromMillisecondsSinceEpoch(csv[0] as int),
      values,
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
