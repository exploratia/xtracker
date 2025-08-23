import 'dart:collection';

import 'package:flutter/material.dart';

import '../model/series/current_value/series_current_value.dart';
import '../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../model/series/data/daily_check/daily_check_value.dart';
import '../model/series/data/habit/habit_value.dart';
import '../model/series/data/series_data_value.dart';
import '../model/series/series_def.dart';
import '../store/stores.dart';

class SeriesCurrentValueProvider with ChangeNotifier {
  final _storeSeriesCurrentValue = Stores.storeSeriesCurrentValue;
  final Map<String, SeriesCurrentValue> _uuid2seriesCurrentValue = HashMap();
  bool _valuesLoaded = false;

  Future<void> fetchDataIfNotYetLoaded() async {
    if (!_valuesLoaded) {
      await fetchData();
      notifyListeners();
    }
  }

  Future<void> fetchData() async {
    var allCurrentValues = await _storeSeriesCurrentValue.getAllCurrentValues();
    for (var currentValue in allCurrentValues) {
      _uuid2seriesCurrentValue[currentValue.seriesDefUuid] = currentValue;
    }
    _valuesLoaded = true;
    notifyListeners();
  }

  Future<void> save(SeriesDef seriesDef, SeriesDataValue seriesDataValue) async {
    await fetchDataIfNotYetLoaded();

    var soFarValue = get(seriesDef);
    if (soFarValue == null || soFarValue.dateTime.isBefore(seriesDataValue.dateTime) || soFarValue.uuid == seriesDataValue.uuid) {
      var seriesCurrentValue = SeriesCurrentValue(seriesDef.uuid, seriesDef.seriesType, seriesDataValue);
      await _storeSeriesCurrentValue.save(seriesCurrentValue);
      _uuid2seriesCurrentValue[seriesDef.uuid] = seriesCurrentValue;

      notifyListeners();
    }
  }

  Future<void> delete(SeriesDef seriesDef) async {
    await fetchDataIfNotYetLoaded();
    await _storeSeriesCurrentValue.delete(seriesDef.uuid);
    _uuid2seriesCurrentValue.remove(seriesDef.uuid);

    notifyListeners();
  }

  Future<void> deleteValue(SeriesDef seriesDef, SeriesDataValue seriesDataValue) async {
    await fetchDataIfNotYetLoaded();

    var soFarValue = get(seriesDef);
    if (soFarValue != null && soFarValue.uuid == seriesDataValue.uuid) {
      await delete(seriesDef);
    }
  }

  SeriesDataValue? get(SeriesDef seriesDef) {
    var currentValue = _uuid2seriesCurrentValue[seriesDef.uuid];
    if (currentValue != null && currentValue.seriesType == seriesDef.seriesType) {
      return currentValue.seriesDataValue;
    }
    return null;
  }

  BloodPressureValue? bloodPressureCurrentValue(SeriesDef seriesDef) {
    var seriesCurrentValue = get(seriesDef);
    if (seriesCurrentValue != null && seriesCurrentValue is BloodPressureValue) {
      return seriesCurrentValue;
    }
    return null;
  }

  DailyCheckValue? dailyCheckCurrentValue(SeriesDef seriesDef) {
    var seriesCurrentValue = get(seriesDef);
    if (seriesCurrentValue != null && seriesCurrentValue is DailyCheckValue) {
      return seriesCurrentValue;
    }
    return null;
  }

  HabitValue? habitCurrentValue(SeriesDef seriesDef) {
    var seriesCurrentValue = get(seriesDef);
    if (seriesCurrentValue != null && seriesCurrentValue is HabitValue) {
      return seriesCurrentValue;
    }
    return null;
  }
}
