import 'dart:collection';

import 'package:flutter/material.dart';

import '../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../model/series/data/series_data.dart';
import '../model/series/series_def.dart';
import '../model/series/series_type.dart';

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
    await _get(seriesDef);
    notifyListeners();
  }

  Future<void> _get(SeriesDef seriesDef) async {
    // TODO load from files
    print('TODO get data from files');
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        _uuid2seriesDataBloodPressure[seriesDef.uuid] = SeriesData<BloodPressureValue>(seriesDef.uuid, []);
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
    return;
  }

  Future<void> _post(SeriesDef seriesDef) async {
    //  await Future.delayed(const Duration(seconds: 10)); // for testing
// TODO save to file

    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        _uuid2seriesDataBloodPressure[seriesDef.uuid] = SeriesData<BloodPressureValue>(seriesDef.uuid, []);
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

  Future<void> _del(SeriesDef seriesDef) async {
    //  await Future.delayed(const Duration(seconds: 10)); // for testing
// TODO delete to file
    _uuid2seriesDataBloodPressure.remove(seriesDef.uuid);
    // TODO remove on other maps
  }

  SeriesData<BloodPressureValue> bloodPressureData(SeriesDef seriesDef) {
    var seriesData = _uuid2seriesDataBloodPressure[seriesDef.uuid];
    return seriesData ?? SeriesData(seriesDef.uuid, []);
  }

  Future<void> add(SeriesDef seriesDef) async {
    await _post(seriesDef);
    notifyListeners();
  }

  Future<void> remove(SeriesDef seriesDef) async {
    await _del(seriesDef);
    notifyListeners();
  }
}
