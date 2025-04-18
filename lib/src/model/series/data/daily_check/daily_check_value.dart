import '../series_data_value.dart';

class DailyCheckValue extends SeriesDataValue {
  // no own members

  DailyCheckValue(super.uuid, super.dateTime);

  DailyCheckValue cloneWith(DateTime dateTime) {
    return DailyCheckValue(uuid, dateTime);
  }

  factory DailyCheckValue.fromJson(Map<String, dynamic> json) =>
      DailyCheckValue(json['uuid'] as String, DateTime.fromMillisecondsSinceEpoch(json['dateTime'] as int));

  @override
  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'dateTime': dateTime.millisecondsSinceEpoch,
      };
}
