import '../series_type.dart';
import 'blood_pressure/blood_pressure_value.dart';
import 'daily_check/daily_check_value.dart';

abstract class SeriesDataValue {
  final String uuid;
  final DateTime dateTime;

  SeriesDataValue(this.uuid, this.dateTime);

  Map<String, dynamic> toJson({bool exportUuid = true});

  static SeriesDataValue fromJson(Map<String, dynamic> json, SeriesType seriesType) {
    return switch (seriesType) {
      SeriesType.bloodPressure => BloodPressureValue.fromJson(json),
      SeriesType.dailyCheck => DailyCheckValue.fromJson(json),
    };
  }
}
