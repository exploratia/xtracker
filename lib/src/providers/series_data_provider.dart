import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/v4.dart';

import '../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../model/series/data/daily_check/daily_check_value.dart';
import '../model/series/data/series_data.dart';
import '../model/series/series_def.dart';
import '../model/series/series_type.dart';
import '../store/stores.dart';
import '../util/logging/flutter_simple_logging.dart';
import 'series_current_value_provider.dart';

class SeriesDataProvider with ChangeNotifier {
  final Map<String, SeriesData<BloodPressureValue>> _uuid2seriesDataBloodPressure = HashMap();
  final Map<String, SeriesData<DailyCheckValue>> _uuid2seriesDataDailyCheck = HashMap();

  Future<void> fetchDataIfNotYetLoaded(SeriesDef seriesDef) async {
    var seriesData = switch (seriesDef.seriesType) {
      SeriesType.bloodPressure => _uuid2seriesDataBloodPressure[seriesDef.uuid],
      SeriesType.dailyCheck => _uuid2seriesDataDailyCheck[seriesDef.uuid],
      SeriesType.monthly =>
        // TODO: Handle this case.
        throw UnimplementedError(),
      SeriesType.free =>
        // TODO: Handle this case.
        throw UnimplementedError()
    };

    if (seriesData == null) {
      await fetchData(seriesDef);
    }
  }

  Future<void> fetchData(SeriesDef seriesDef) async {
    await _createSeriesDataIfNotExists(seriesDef);
    notifyListeners();
  }

  Future<void> add(SeriesDef seriesDef) async {
    await _createSeriesDataIfNotExists(seriesDef);
    notifyListeners();
  }

  Future<void> _createSeriesDataIfNotExists(SeriesDef seriesDef) async {
    //  await Future.delayed(const Duration(seconds: 10)); // for testing

    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        var seriesData = _uuid2seriesDataBloodPressure[seriesDef.uuid];
        if (seriesData == null) {
          var store = Stores.getOrCreateSeriesDataStore(seriesDef);
          var list = await store.getAllSeriesDataValuesAsBloodPressureValue();
          // TODO only for dev - remove!
          if (list.isEmpty) {
            list = [
              BloodPressureValue(const UuidV4().generate().toString(), DateTime.now(), 120, 80),
              BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(days: 28)), 140, 80),
              BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 25)), 140, 80),
              BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 28)), 130, 97),
              BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 30)), 120, 75),
              BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 40)), 155, 110),
              // ...List.generate(
              //     10040,
              //     (index) => BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(Duration(hours: 40 + index * 25)),
              //         (155 - 5 * sin(index * 0.01)).truncate(), (80 - 10 * sin(index * 0.01 + 1)).truncate())),
            ];
            await store.saveAll(list);
            list = await store.getAllSeriesDataValuesAsBloodPressureValue();
          }

          seriesData = SeriesData<BloodPressureValue>(seriesDef.uuid, list);
          seriesData.sort();
          _uuid2seriesDataBloodPressure[seriesDef.uuid] = seriesData;
        }
      case SeriesType.dailyCheck:
        var seriesData = _uuid2seriesDataDailyCheck[seriesDef.uuid];
        if (seriesData == null) {
          var store = Stores.getOrCreateSeriesDataStore(seriesDef);
          var list = await store.getAllSeriesDataValuesAsDailyCheckValue();
          // TODO only for dev - remove!
          if (list.isEmpty) {
            list = [
              DailyCheckValue(const UuidV4().generate().toString(), DateTime.now()),
              DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(days: 28))),
              DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 25))),
              DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 28))),
              DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 30))),
              DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 40))),
              // ...List.generate(
              //     10040, (index) => DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(Duration(hours: 40 + index * 25)))),
            ];
            await store.saveAll(list);
            list = await store.getAllSeriesDataValuesAsDailyCheckValue();
          }

          seriesData = SeriesData<DailyCheckValue>(seriesDef.uuid, list);
          seriesData.sort();
          _uuid2seriesDataDailyCheck[seriesDef.uuid] = seriesData;
        }
      case SeriesType.monthly:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SeriesType.free:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Future<void> delete(SeriesDef seriesDef, BuildContext context) async {
    SeriesCurrentValueProvider seriesCurrentValueProvider = context.read<SeriesCurrentValueProvider>();

    // delete current value
    await seriesCurrentValueProvider.delete(seriesDef);
    //  await Future.delayed(const Duration(seconds: 10)); // for testing

    await Stores.dropSeriesDataStore(seriesDef);
    _uuid2seriesDataBloodPressure.remove(seriesDef.uuid);
    _uuid2seriesDataDailyCheck.remove(seriesDef.uuid);
    // TODO remove on other maps
    notifyListeners();
  }

  SeriesData? seriesData(SeriesDef seriesDef) {
    return switch (seriesDef.seriesType) {
      SeriesType.bloodPressure => bloodPressureData(seriesDef),
      SeriesType.dailyCheck => dailyCheckData(seriesDef),
      // TODO: Handle this case.
      SeriesType.monthly => throw UnimplementedError(),
      // TODO: Handle this case.
      SeriesType.free => throw UnimplementedError(),
    };
  }

  SeriesData<BloodPressureValue>? bloodPressureData(SeriesDef seriesDef) {
    var seriesData = _uuid2seriesDataBloodPressure[seriesDef.uuid];
    return seriesData;
  }

  SeriesData<DailyCheckValue>? dailyCheckData(SeriesDef seriesDef) {
    var seriesData = _uuid2seriesDataDailyCheck[seriesDef.uuid];
    return seriesData;
  }

  Future<void> addValue(SeriesDef seriesDef, dynamic value, BuildContext context) async {
    await _addOrUpdateValue(seriesDef, value, _Action.insert, context);
  }

  Future<void> updateValue(SeriesDef seriesDef, dynamic value, BuildContext context) async {
    await _addOrUpdateValue(seriesDef, value, _Action.update, context);
  }

  Future<void> deleteValue(SeriesDef seriesDef, dynamic value, BuildContext context) async {
    await _addOrUpdateValue(seriesDef, value, _Action.delete, context);
  }

  Future<void> _addOrUpdateValue(SeriesDef seriesDef, dynamic value, _Action action, BuildContext context) async {
    SeriesCurrentValueProvider seriesCurrentValueProvider = context.read<SeriesCurrentValueProvider>();

    await fetchDataIfNotYetLoaded(seriesDef);
    var store = Stores.getOrCreateSeriesDataStore(seriesDef);

    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        if (value is! BloodPressureValue) {
          var errMsg = 'Failure on storing series value: Type mismatch! Expected: "$BloodPressureValue", got: "${value.runtimeType}"';
          SimpleLogging.w(errMsg);
          throw Exception(errMsg);
        }
        var seriesData = _uuid2seriesDataBloodPressure[seriesDef.uuid];
        if (seriesData == null) {
          var errMsg = "Failed to create/load series data for ${seriesDef.name} (type: ${seriesDef.seriesType.typeName})!";
          SimpleLogging.w(errMsg);
          throw Exception(errMsg);
        }
        if (action == _Action.insert) {
          seriesData.insert(value);
          await store.save(value);
          await seriesCurrentValueProvider.save(seriesDef, value);
        } else if (action == _Action.update) {
          seriesData.update(value);
          await store.save(value);
          await seriesCurrentValueProvider.save(seriesDef, value);
        } else if (action == _Action.delete) {
          seriesData.delete(value);
          await store.delete(value);
          await seriesCurrentValueProvider.deleteValue(seriesDef, value);
        }
        seriesData.sort();
      case SeriesType.dailyCheck:
        if (value is! DailyCheckValue) {
          var errMsg = 'Failure on storing series value: Type mismatch! Expected: "$DailyCheckValue", got: "${value.runtimeType}"';
          SimpleLogging.w(errMsg);
          throw Exception(errMsg);
        }
        var seriesData = _uuid2seriesDataDailyCheck[seriesDef.uuid];
        if (seriesData == null) {
          var errMsg = "Failed to create/load series data for ${seriesDef.name} (type: ${seriesDef.seriesType.typeName})!";
          SimpleLogging.w(errMsg);
          throw Exception(errMsg);
        }
        if (action == _Action.insert) {
          seriesData.insert(value);
          await store.save(value);
          await seriesCurrentValueProvider.save(seriesDef, value);
        } else if (action == _Action.update) {
          seriesData.update(value);
          await store.save(value);
          await seriesCurrentValueProvider.save(seriesDef, value);
        } else if (action == _Action.delete) {
          seriesData.delete(value);
          await store.delete(value);
          await seriesCurrentValueProvider.deleteValue(seriesDef, value);
        }
        seriesData.sort();
      case SeriesType.monthly:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SeriesType.free:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    notifyListeners();
  }
}

enum _Action {
  insert,
  update,
  delete;
}
