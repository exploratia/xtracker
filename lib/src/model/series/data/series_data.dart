import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../providers/series_data_provider.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../widgets/series/data/input/blood_pressure/blood_pressure_input.dart';
import '../../../widgets/series/data/input/daily_check/daily_check_input.dart';
import '../../../widgets/series/data/input/habit/habit_input.dart';
import '../series_def.dart';
import '../series_type.dart';
import 'blood_pressure/blood_pressure_value.dart';
import 'daily_check/daily_check_value.dart';
import 'habit/habit_value.dart';
import 'series_data_value.dart';

class SeriesData<T extends SeriesDataValue> {
  /// same as in SeriesDef
  final String seriesDefUuid;

  final List<T> data;

  SeriesData(this.seriesDefUuid, this.data);

  Map<String, dynamic> toJson({bool exportUuid = true}) => {
        'uuid': seriesDefUuid,
        'version': 1,
        'data': [...data.map((e) => e.toJson(exportUuid: exportUuid))],
      };

  static SeriesData<BloodPressureValue> fromJsonBloodPressureData(Map<String, dynamic> json) => SeriesData(
        json['uuid'] as String,
        [...(json['data'] as List<dynamic>).map((e) => BloodPressureValue.fromJson(e))],
        // if version is required: json['version'] as int? ?? 1
      );

  static SeriesData<DailyCheckValue> fromJsonDailyCheckData(Map<String, dynamic> json) => SeriesData(
        json['uuid'] as String,
        [...(json['data'] as List<dynamic>).map((e) => DailyCheckValue.fromJson(e))],
        // if version is required: json['version'] as int? ?? 1
      );

  static SeriesData<HabitValue> fromJsonHabitData(Map<String, dynamic> json) => SeriesData(
        json['uuid'] as String,
        [...(json['data'] as List<dynamic>).map((e) => HabitValue.fromJson(e))],
        // if version is required: json['version'] as int? ?? 1
      );

  bool isEmpty() {
    return data.isEmpty;
  }

  void insert(T value) {
    data.add(value);
    // sort - probably not necessary but maybe date could also be set?
    sort();
  }

  void insertAll(Iterable<T> values) {
    data.addAll(values);
    // sort - probably not necessary but maybe date could also be set?
    sort();
  }

  void sort() {
    data.sort((a, b) => a.dateTime.millisecondsSinceEpoch.compareTo(b.dateTime.millisecondsSinceEpoch));
  }

  void update(T value) {
    var idx = data.indexWhere((element) => element.uuid == value.uuid);
    if (idx < 0) return;
    data.removeAt(idx);
    data.insert(idx, value);
  }

  void delete(T value) {
    data.remove(value);
  }

  void deleteById(String uuid) {
    data.removeWhere((element) => element.uuid == uuid);
  }

  /// returns reduced copy (must not be used edit)
  SeriesData<T> reduceToNewerThen(DateTime dateTime) {
    List<T> reducedSeriesItems = data.where((item) => item.dateTime.isAfter(dateTime)).toList();
    return SeriesData(seriesDefUuid, reducedSeriesItems);
  }

  static Future<void> showSeriesDataInputDlg(BuildContext context, SeriesDef seriesDef, {dynamic value}) async {
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        {
          BloodPressureValue? bloodPressureValue;
          if (value is BloodPressureValue) bloodPressureValue = value;
          var val = await BloodPressureQuickInput.showInputDlg(context, seriesDef, bloodPressureValue: bloodPressureValue);
          if (val == null) return;
          if (context.mounted) {
            var seriesDataProvider = context.read<SeriesDataProvider>();

            try {
              if (bloodPressureValue == null) {
                await seriesDataProvider.addValue(seriesDef, val, context); // insert
              } else {
                await seriesDataProvider.updateValue(seriesDef, val, context); // update
              }
            } catch (ex) {
              SimpleLogging.w('Failed to store blood pressure value.', error: ex);
              if (context.mounted) {
                Dialogs.simpleErrOkDialog(ex.toString(), context);
              }
            }
          }
        }
      case SeriesType.dailyCheck:
        {
          DailyCheckValue? dailyCheckValue;
          if (value is DailyCheckValue) dailyCheckValue = value;
          var val = await DailyCheckInput.showInputDlg(context, seriesDef, dailyCheckValue: dailyCheckValue);
          if (val == null) return;
          if (context.mounted) {
            var seriesDataProvider = context.read<SeriesDataProvider>();

            try {
              if (dailyCheckValue == null) {
                await seriesDataProvider.addValue(seriesDef, val, context); // insert
              } else {
                await seriesDataProvider.updateValue(seriesDef, val, context); // update
              }
            } catch (ex) {
              SimpleLogging.w('Failed to store daily check value.', error: ex);
              if (context.mounted) {
                Dialogs.simpleErrOkDialog(ex.toString(), context);
              }
            }
          }
        }
      case SeriesType.habit:
        {
          HabitValue? habitValue;
          if (value is HabitValue) habitValue = value;
          var val = await HabitInput.showInputDlg(context, seriesDef, habitValue: habitValue);
          if (val == null) return;
          if (context.mounted) {
            var seriesDataProvider = context.read<SeriesDataProvider>();

            try {
              if (habitValue == null) {
                await seriesDataProvider.addValue(seriesDef, val, context); // insert
              } else {
                await seriesDataProvider.updateValue(seriesDef, val, context); // update
              }
            } catch (ex) {
              SimpleLogging.w('Failed to store habit value.', error: ex);
              if (context.mounted) {
                Dialogs.simpleErrOkDialog(ex.toString(), context);
              }
            }
          }
        }
    }
  }
}
