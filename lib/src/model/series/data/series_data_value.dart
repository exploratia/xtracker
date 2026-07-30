import 'package:uuid/uuid.dart';

import '../../../util/json_reader.dart';
import '../series_def.dart';
import '../series_type.dart';
import 'blood_pressure/blood_pressure_value.dart';
import 'custom/custom_value.dart';
import 'daily_check/daily_check_value.dart';
import 'daily_life/daily_life_value.dart';
import 'datetime_item.dart';
import 'habit/habit_value.dart';
import 'monthly/monthly_value.dart';

abstract class SeriesDataValue implements DateTimeItem {
  final String uuid;
  final DateTime dateTime;

  SeriesDataValue(this.uuid, this.dateTime);

  @override
  DateTime get datetime {
    return dateTime;
  }

  Map<String, dynamic> toJson({bool exportUuid = true});

  /// Creates a new value with copied measurement data and a new timestamp.
  ///
  /// Habit and daily-check values intentionally cannot be duplicated.
  SeriesDataValue duplicateAt(DateTime dateTime) {
    final newUuid = const Uuid().v4();
    return switch (this) {
      BloodPressureValue value => BloodPressureValue(newUuid, dateTime, value.high, value.low, value.medication),
      DailyLifeValue value => DailyLifeValue(newUuid, dateTime, value.tagId),
      MonthlyValue value => MonthlyValue(newUuid, dateTime, Map.of(value.values), value.tagId),
      CustomValue value => CustomValue(newUuid, dateTime, Map.of(value.values), value.tagId),
      HabitValue() || DailyCheckValue() => throw UnsupportedError('This series value type cannot be duplicated.'),
      _ => throw UnsupportedError('This series value type cannot be duplicated.'),
    };
  }

  static SeriesDataValue fromJson(JsonReader json, SeriesType seriesType) {
    return switch (seriesType) {
      SeriesType.bloodPressure => BloodPressureValue.fromJson(json),
      SeriesType.dailyCheck => DailyCheckValue.fromJson(json),
      SeriesType.dailyLife => DailyLifeValue.fromJson(json),
      SeriesType.habit => HabitValue.fromJson(json),
      SeriesType.custom => CustomValue.fromJson(json),
      SeriesType.monthly => MonthlyValue.fromJson(json),
    };
  }

  List<dynamic> toCSVList(SeriesDef seriesDef);
}
