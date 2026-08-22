import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../providers/series_current_value_provider.dart';
import '../../../providers/series_data_provider.dart';
import '../../../store/migration/db_migration.dart';
import '../../../util/dialogs.dart';
import '../../../util/globals.dart';
import '../../../util/json_reader.dart';
import '../../../util/json_version.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/motion_utils.dart';
import '../../../widgets/series/data/input/blood_pressure/blood_pressure_input.dart';
import '../../../widgets/series/data/input/custom/custom_input.dart';
import '../../../widgets/series/data/input/daily_check/daily_check_input.dart';
import '../../../widgets/series/data/input/daily_life/daily_life_input.dart';
import '../../../widgets/series/data/input/habit/habit_input.dart';
import '../../../widgets/series/data/input/input_result.dart';
import '../../../widgets/series/data/input/monthly/monthly_input.dart';
import '../series_def.dart';
import '../series_type.dart';
import 'blood_pressure/blood_pressure_value.dart';
import 'custom/custom_value.dart';
import 'daily_check/daily_check_value.dart';
import 'daily_life/daily_life_value.dart';
import 'habit/habit_value.dart';
import 'monthly/monthly_value.dart';
import 'series_data_value.dart';

class SeriesData<T extends SeriesDataValue> {
  /// same as in SeriesDef
  final String seriesDefUuid;

  final List<T> data;

  SeriesData(this.seriesDefUuid, this.data);

  Map<String, dynamic> toJson({bool exportUuid = true}) => {
    'uuid': seriesDefUuid,
    'version': DbMigration.latestVersion,
    'data': [...data.map((e) => e.toJson(exportUuid: exportUuid))],
  };

  static SeriesData<BloodPressureValue> fromJsonBloodPressureData(JsonReader json, {String? seriesDefUuid}) {
    JsonVersion.validateNotNewer(json, 'seriesData', validateType: false);
    return SeriesData(
      json.asStringOr('uuid', seriesDefUuid ?? Globals.invalid),
      [...json.asReader('data').asReaders().map((e) => BloodPressureValue.fromJson(e))],
    );
  }

  static SeriesData<DailyCheckValue> fromJsonDailyCheckData(JsonReader json, {String? seriesDefUuid}) {
    JsonVersion.validateNotNewer(json, 'seriesData', validateType: false);
    return SeriesData(
      json.asStringOr('uuid', seriesDefUuid ?? Globals.invalid),
      [...json.asReader('data').asReaders().map((e) => DailyCheckValue.fromJson(e))],
    );
  }

  static SeriesData<DailyLifeValue> fromJsonDailyLifeData(JsonReader json, {String? seriesDefUuid}) {
    JsonVersion.validateNotNewer(json, 'seriesData', validateType: false);
    return SeriesData(
      json.asStringOr('uuid', seriesDefUuid ?? Globals.invalid),
      [...json.asReader('data').asReaders().map((e) => DailyLifeValue.fromJson(e))],
    );
  }

  static SeriesData<HabitValue> fromJsonHabitData(JsonReader json, {String? seriesDefUuid}) {
    JsonVersion.validateNotNewer(json, 'seriesData', validateType: false);
    return SeriesData(
      json.asStringOr('uuid', seriesDefUuid ?? Globals.invalid),
      [...json.asReader('data').asReaders().map((e) => HabitValue.fromJson(e))],
    );
  }

  static SeriesData<CustomValue> fromJsonCustomData(JsonReader json, {String? seriesDefUuid}) {
    JsonVersion.validateNotNewer(json, 'seriesData', validateType: false);
    return SeriesData(
      json.asStringOr('uuid', seriesDefUuid ?? Globals.invalid),
      [...json.asReader('data').asReaders().map((e) => CustomValue.fromJson(e))],
    );
  }

  static SeriesData<MonthlyValue> fromJsonMonthlyData(JsonReader json, {String? seriesDefUuid}) {
    JsonVersion.validateNotNewer(json, 'seriesData', validateType: false);
    return SeriesData(
      json.asStringOr('uuid', seriesDefUuid ?? Globals.invalid),
      [...json.asReader('data').asReaders().map((e) => MonthlyValue.fromJson(e))],
    );
  }

  List<List<dynamic>> toCSVLists(SeriesDef seriesDef) => [...data.map((e) => e.toCSVList(seriesDef))];

  static SeriesData<BloodPressureValue> fromCSVBloodPressureData(SeriesDef seriesDef, List<List<dynamic>> csv) => SeriesData(
    seriesDef.uuid,
    [...csv.map((e) => BloodPressureValue.fromCSVList(e))],
  );

  static SeriesData<DailyCheckValue> fromCSVDailyCheckData(SeriesDef seriesDef, List<List<dynamic>> csv) => SeriesData(
    seriesDef.uuid,
    [...csv.map((e) => DailyCheckValue.fromCSVList(e))],
  );

  static SeriesData<DailyLifeValue> fromCSVDailyLifeData(SeriesDef seriesDef, List<List<dynamic>> csv) {
    // build resolver map
    var tags = seriesDef.dailyLifeTagsSettingsReadonly().tags;
    Map<String, String> tagName2TagId = {};
    for (var tag in tags) {
      tagName2TagId[tag.name] = tag.tagId;
    }
    return SeriesData(
      seriesDef.uuid,
      [...csv.map((e) => DailyLifeValue.fromCSVList(e, tagName2TagId))],
    );
  }

  static SeriesData<HabitValue> fromCSVHabitData(SeriesDef seriesDef, List<List<dynamic>> csv) => SeriesData(
    seriesDef.uuid,
    [...csv.map((e) => HabitValue.fromCSVList(e))],
  );

  static SeriesData<CustomValue> fromCSVCustomData(SeriesDef seriesDef, List<List<dynamic>> csv) => SeriesData(
    seriesDef.uuid,
    [...csv.map((e) => CustomValue.fromCSVList(e, seriesDef))],
  );

  static SeriesData<MonthlyValue> fromCSVMonthlyData(SeriesDef seriesDef, List<List<dynamic>> csv) => SeriesData(
    seriesDef.uuid,
    [...csv.map((e) => MonthlyValue.fromCSVList(e, seriesDef))],
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
    deleteById(value.uuid);
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

  /// Shows the value input dialog in create or edit mode.
  ///
  /// When [inputMode] is omitted, the mode is inferred from whether [value]
  /// exists. Create mode may still receive a value as an input template.
  static Future<void> showSeriesDataInputDlg(
    BuildContext context,
    SeriesDef seriesDef, {
    SeriesDataValue? value,
    SeriesDataInputMode? inputMode,
  }) async {
    var seriesDataProvider = context.read<SeriesDataProvider>();
    var seriesCurrentValueProvider = context.read<SeriesCurrentValueProvider>();
    final deletionDelay = MotionUtils.resolve(context, SeriesDataMutation.deletionDuration);
    final resolvedInputMode = inputMode ?? (value == null ? SeriesDataInputMode.create : SeriesDataInputMode.edit);
    if (resolvedInputMode == SeriesDataInputMode.edit && value == null) {
      throw ArgumentError.value(value, 'value', 'An existing value is required in edit mode.');
    }

    InputResult<SeriesDataValue>? inputResult;
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        inputResult = await BloodPressureQuickInput.showInputDlg(
          context,
          seriesDef,
          bloodPressureValue: (value is BloodPressureValue) ? value : null,
          inputMode: resolvedInputMode,
        );
      case SeriesType.dailyCheck:
        inputResult = await DailyCheckInput.showInputDlg(
          context,
          seriesDef,
          dailyCheckValue: (value is DailyCheckValue) ? value : null,
          inputMode: resolvedInputMode,
        );
      case SeriesType.dailyLife:
        inputResult = await DailyLifeInput.showInputDlg(
          context,
          seriesDef,
          dailyLifeValue: (value is DailyLifeValue) ? value : null,
          inputMode: resolvedInputMode,
        );
      case SeriesType.habit:
        inputResult = await HabitInput.showInputDlg(
          context,
          seriesDef,
          habitValue: (value is HabitValue) ? value : null,
          inputMode: resolvedInputMode,
        );
      case SeriesType.custom:
        inputResult = await CustomInput.showInputDlg(
          context,
          seriesDef,
          customValue: (value is CustomValue) ? value : null,
          inputMode: resolvedInputMode,
        );
      case SeriesType.monthly:
        inputResult = await MonthlyInput.showInputDlg(
          context,
          seriesDef,
          monthlyValue: (value is MonthlyValue) ? value : null,
          inputMode: resolvedInputMode,
        );
    }

    if (inputResult == null) {
      // also on canceled set recently updated to ensure scrolling in series view to the act series
      seriesCurrentValueProvider.setRecentlyUpdatedSeries(seriesDef.uuid);
      return; // canceled
    }
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
          SimpleLogging.w('Failed to store ${seriesDef.seriesType.name} value.', error: ex);
          if (context.mounted) {
            Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_saveFailed.tr(), context);
          }
        }
      case InputResultAction.delete:
        try {
          await seriesDataProvider.deleteValue(
            seriesDef,
            inputResult.seriesDataValue,
            seriesCurrentValueProvider,
            deletionDelay: deletionDelay,
          );
        } catch (err) {
          SimpleLogging.w('Failed to delete ${seriesDef.seriesType.name} value.', error: err);
          if (context.mounted) {
            Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_deleteFailed.tr(), context);
          }
        }
    }
  }
}
