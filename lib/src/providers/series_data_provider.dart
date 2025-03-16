import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/v4.dart';

import '../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../model/series/data/series_data.dart';
import '../model/series/series_def.dart';
import '../model/series/series_type.dart';
import '../store/stores.dart';
import '../util/logging/flutter_simple_logging.dart';

class SeriesDataProvider with ChangeNotifier {
  final Map<String, SeriesData<BloodPressureValue>> _uuid2seriesDataBloodPressure = HashMap();

  Future<void> fetchDataIfNotYetLoaded(SeriesDef seriesDef) async {
    var seriesData = switch (seriesDef.seriesType) {
      SeriesType.bloodPressure => _uuid2seriesDataBloodPressure[seriesDef.uuid],
      SeriesType.dailyCheck =>
        // TODO: Handle this case.
        throw UnimplementedError(),
      SeriesType.monthly =>
        // TODO: Handle this case.
        throw UnimplementedError(),
      SeriesType.free =>
        // TODO: Handle this case.
        throw UnimplementedError()
    };

    if (seriesData == null) {
      await fetchData(seriesDef);
      notifyListeners();
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
// TODO load / save to file

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
              ...List.generate(
                  10040,
                  (index) => BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(Duration(hours: 40 + index * 25)),
                      (155 - 5 * sin(index * 0.01)).truncate(), (80 - 10 * sin(index * 0.01 + 1)).truncate())),
            ];
            await store.saveAll(list);
            list = await store.getAllSeriesDataValuesAsBloodPressureValue();
          }

          seriesData = SeriesData<BloodPressureValue>(seriesDef.uuid, list);
          seriesData.sort();
          _uuid2seriesDataBloodPressure[seriesDef.uuid] = seriesData;
        }
      case SeriesType.dailyCheck:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SeriesType.monthly:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SeriesType.free:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Future<void> delete(SeriesDef seriesDef) async {
    //  await Future.delayed(const Duration(seconds: 10)); // for testing
    await Stores.dropSeriesDataStore(seriesDef);
    _uuid2seriesDataBloodPressure.remove(seriesDef.uuid);
    // TODO remove on other maps
    notifyListeners();
  }

  SeriesData<BloodPressureValue>? bloodPressureData(SeriesDef seriesDef) {
    var seriesData = _uuid2seriesDataBloodPressure[seriesDef.uuid];
    return seriesData;
  }

  Future<void> addValue(SeriesDef seriesDef, dynamic value) async {
    await _addOrUpdateValue(seriesDef, value, _Action.insert);
  }

  Future<void> updateValue(SeriesDef seriesDef, dynamic value) async {
    await _addOrUpdateValue(seriesDef, value, _Action.update);
  }

  Future<void> deleteValue(SeriesDef seriesDef, dynamic value) async {
    await _addOrUpdateValue(seriesDef, value, _Action.delete);
  }

  Future<void> _addOrUpdateValue(SeriesDef seriesDef, dynamic value, _Action action) async {
    await fetchDataIfNotYetLoaded(seriesDef);
// TODO save file
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
        } else if (action == _Action.update) {
          seriesData.update(value);
        } else if (action == _Action.delete) {
          seriesData.delete(value);
        }
        seriesData.sort();
      case SeriesType.dailyCheck:
        // TODO: Handle this case.
        throw UnimplementedError();
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
