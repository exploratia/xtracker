import '../series_data_value.dart';

abstract class MultiValue extends SeriesDataValue {
  final Map<String, double> values;

  MultiValue(super.uuid, super.dateTime, this.values);

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
        if (exportUuid) 'uuid': uuid,
        'utcMs': dateTime.millisecondsSinceEpoch,
        'values': values,
      };

  @override
  String toString() {
    return 'MultiValue{...}';
  }
}
