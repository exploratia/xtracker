import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../providers/series_current_value_provider.dart';
import '../../../providers/series_data_provider.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../widgets/series/data/input/blood_pressure/blood_pressure_input.dart';
import '../../../widgets/series/data/input/daily_check/daily_check_input.dart';
import '../../../widgets/series/data/input/habit/habit_input.dart';
import '../../../widgets/series/data/input/input_result.dart';
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

  static List<U> reduceDataToNewerThen<U extends SeriesDataValue>(List<U> data, DateTime dateTime) {
    var reduced = data.where((item) => item.dateTime.isAfter(dateTime)).toList();
    return reduced;
  }

  static Future<void> showSeriesDataInputDlg(BuildContext context, SeriesDef seriesDef, {SeriesDataValue? value}) async {
    var seriesDataProvider = context.read<SeriesDataProvider>();
    var seriesCurrentValueProvider = context.read<SeriesCurrentValueProvider>();

    InputResult<SeriesDataValue>? inputResult;
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        inputResult = await BloodPressureQuickInput.showInputDlg(context, seriesDef, bloodPressureValue: (value is BloodPressureValue) ? value : null);
      case SeriesType.dailyCheck:
        inputResult = await DailyCheckInput.showInputDlg(context, seriesDef, dailyCheckValue: (value is DailyCheckValue) ? value : null);
      case SeriesType.habit:
        inputResult = await HabitInput.showInputDlg(context, seriesDef, habitValue: (value is HabitValue) ? value : null);
    }

    if (inputResult == null) return; // canceled
    switch (inputResult.action) {
      case InputResultAction.insert:
      case InputResultAction.update:
        try {
          if (inputResult.action == InputResultAction.insert) {
            await seriesDataProvider.addValue(seriesDef, inputResult.seriesDataValue, seriesCurrentValueProvider); // insert
          } else {
            await seriesDataProvider.updateValue(seriesDef, inputResult.seriesDataValue, seriesCurrentValueProvider); // update
          }
        } catch (ex) {
          SimpleLogging.w('Failed to store ${seriesDef.seriesType.typeName} value.', error: ex);
          if (context.mounted) {
            Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_saveFailed.tr(), context);
          }
        }
      case InputResultAction.delete:
        try {
          await seriesDataProvider.deleteValue(seriesDef, inputResult.seriesDataValue, seriesCurrentValueProvider);
        } catch (err) {
          SimpleLogging.w('Failed to delete ${seriesDef.seriesType.typeName} value.', error: err);
          if (context.mounted) {
            Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_deleteFailed.tr(), context);
          }
        }
    }
  }
}
