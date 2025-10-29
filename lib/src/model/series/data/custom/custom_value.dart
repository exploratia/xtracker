import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../series_data_value.dart';

class CustomValue extends SeriesDataValue {
  final Map<String, double> values;

  CustomValue(super.uuid, super.dateTime, this.values);

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
        if (exportUuid) 'uuid': uuid,
        'utcMs': dateTime.millisecondsSinceEpoch,
        'values': values,
      };

  factory CustomValue.fromJson(Map<String, dynamic> json) {
    Map<String, double> values = {};
    var jValues = json['values'] as Map?;
    if (jValues != null) {
      for (var entry in jValues.entries) {
        if (entry.key is String && entry.value is double) {
          values[entry.key] = entry.value;
        }
      }
    }
    return CustomValue(
      json['uuid'] as String? ?? const Uuid().v4().toString(),
      DateTime.fromMillisecondsSinceEpoch(json['utcMs'] as int),
      values,
    );
  }

  @override
  String toString() {
    return 'CustomValue{...}';
  }

  static CustomValue checkOnCustomValue(dynamic value) {
    if (value is CustomValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$CustomValue", got: "${value.runtimeType}"';
    throw Ex(errMsg);
  }
}
