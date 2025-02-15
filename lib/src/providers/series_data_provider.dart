import 'dart:collection';

import 'package:flutter/material.dart';

import '../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../model/series/data/series_data.dart';
import '../model/series/series_def.dart';
import '../model/series/series_type.dart';
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
          // TODO try load from file - if not exists create
          seriesData = SeriesData<BloodPressureValue>(seriesDef.uuid, []);
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

  Future<void> remove(SeriesDef seriesDef) async {
    await _del(seriesDef);
    notifyListeners();
  }

  Future<void> _del(SeriesDef seriesDef) async {
    //  await Future.delayed(const Duration(seconds: 10)); // for testing
// TODO delete  file
    _uuid2seriesDataBloodPressure.remove(seriesDef.uuid);
    // TODO remove on other maps
  }

  SeriesData<BloodPressureValue>? bloodPressureData(SeriesDef seriesDef) {
    var seriesData = _uuid2seriesDataBloodPressure[seriesDef.uuid];
    return seriesData;
  }

  Future<void> addBloodPressureValue(SeriesDef seriesDef, BloodPressureValue value) async {
    await _createSeriesDataIfNotExists(seriesDef);
    var seriesData = bloodPressureData(seriesDef);
    if (seriesData == null) {
      SimpleLogging.w("Failed to create/load series data!");
      return;
    }

    seriesData.add(value);

    notifyListeners();
  }
}
