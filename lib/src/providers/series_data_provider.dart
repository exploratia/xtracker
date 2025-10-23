import 'dart:collection';

import 'package:flutter/material.dart';

import '../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../model/series/data/custom/custom_value.dart';
import '../model/series/data/daily_check/daily_check_value.dart';
import '../model/series/data/daily_life/daily_life_value.dart';
import '../model/series/data/habit/habit_value.dart';
import '../model/series/data/series_data.dart';
import '../model/series/data/series_data_value.dart';
import '../model/series/series_def.dart';
import '../model/series/series_type.dart';
import '../store/stores.dart';
import '../util/ex.dart';
import '../util/logging/flutter_simple_logging.dart';
import 'series_current_value_provider.dart';

class SeriesDataProvider with ChangeNotifier {
  final Map<String, SeriesData<BloodPressureValue>> _uuid2seriesDataBloodPressure = HashMap();
  final Map<String, SeriesData<DailyCheckValue>> _uuid2seriesDataDailyCheck = HashMap();
  final Map<String, SeriesData<DailyLifeValue>> _uuid2seriesDataDailyLife = HashMap();
  final Map<String, SeriesData<HabitValue>> _uuid2seriesDataHabit = HashMap();
  final Map<String, SeriesData<CustomValue>> _uuid2seriesDataCustom = HashMap();

  Future<void> fetchDataIfNotYetLoaded(SeriesDef seriesDef) async {
    var seriesData = switch (seriesDef.seriesType) {
      SeriesType.bloodPressure => _uuid2seriesDataBloodPressure[seriesDef.uuid],
      SeriesType.dailyCheck => _uuid2seriesDataDailyCheck[seriesDef.uuid],
      SeriesType.dailyLife => _uuid2seriesDataDailyLife[seriesDef.uuid],
      SeriesType.habit => _uuid2seriesDataHabit[seriesDef.uuid],
      SeriesType.custom => _uuid2seriesDataCustom[seriesDef.uuid],
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
          // // TODO only for dev - remove!
          // if (list.isEmpty) {
          //   list = [
          //     BloodPressureValue(const UuidV4().generate().toString(), DateTime.now(), 120, 80, false),
          //     BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(days: 28)), 140, 80, false),
          //     BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 25)), 140, 80, false),
          //     BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 28)), 130, 97, false),
          //     BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 30)), 120, 75, false),
          //     BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 40)), 155, 110, false),
          //     // ...List.generate(
          //     //     10040,
          //     //     (index) => BloodPressureValue(const UuidV4().generate().toString(), DateTime.now().subtract(Duration(hours: 40 + index * 25)),
          //     //         (155 - 5 * sin(index * 0.01)).truncate(), (80 - 10 * sin(index * 0.01 + 1)).truncate())),
          //   ];
          //   await store.saveAll(list);
          //   list = await store.getAllSeriesDataValuesAsBloodPressureValue();
          // }

          seriesData = SeriesData<BloodPressureValue>(seriesDef.uuid, list);
          seriesData.sort();
          _uuid2seriesDataBloodPressure[seriesDef.uuid] = seriesData;
        }
      case SeriesType.dailyCheck:
        var seriesData = _uuid2seriesDataDailyCheck[seriesDef.uuid];
        if (seriesData == null) {
          var store = Stores.getOrCreateSeriesDataStore(seriesDef);
          var list = await store.getAllSeriesDataValuesAsDailyCheckValue();
          // // TODO only for dev - remove!
          // if (list.isEmpty) {
          //   list = [
          //     DailyCheckValue(const UuidV4().generate().toString(), DateTime.now()),
          //     DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(days: 28))),
          //     DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 25))),
          //     DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 28))),
          //     DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 30))),
          //     DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(const Duration(hours: 40))),
          //     // ...List.generate(
          //     //     10040, (index) => DailyCheckValue(const UuidV4().generate().toString(), DateTime.now().subtract(Duration(hours: 40 + index * 25)))),
          //   ];
          //   await store.saveAll(list);
          //   list = await store.getAllSeriesDataValuesAsDailyCheckValue();
          // }

          seriesData = SeriesData<DailyCheckValue>(seriesDef.uuid, list);
          seriesData.sort();
          _uuid2seriesDataDailyCheck[seriesDef.uuid] = seriesData;
        }
      case SeriesType.dailyLife:
        var seriesData = _uuid2seriesDataDailyLife[seriesDef.uuid];
        if (seriesData == null) {
          var store = Stores.getOrCreateSeriesDataStore(seriesDef);
          var list = await store.getAllSeriesDataValuesAsDailyLifeValue();

          seriesData = SeriesData<DailyLifeValue>(seriesDef.uuid, list);
          seriesData.sort();
          _uuid2seriesDataDailyLife[seriesDef.uuid] = seriesData;
        }
      case SeriesType.habit:
        var seriesData = _uuid2seriesDataHabit[seriesDef.uuid];
        if (seriesData == null) {
          var store = Stores.getOrCreateSeriesDataStore(seriesDef);
          var list = await store.getAllSeriesDataValuesAsHabitValue();

          // // TODO only for dev - remove!
          // if (list.isEmpty) {
          //   Random random = Random();
          //
          //   // for (var i = 0; i < 365 * 5; ++i) {
          //   for (var i = 0; i < 365 * 1; i += 100) {
          //     // for (var i = 0; i < 20; ++i) {
          //     int randomNumber = random.nextInt(10);
          //     for (var j = 0; j < randomNumber; ++j) {
          //       list.add(HabitValue(const UuidV4().generate().toString(), DateTime.now().subtract(Duration(days: i, hours: j * 2))));
          //     }
          //   }
          //   await store.saveAll(list);
          //   list = await store.getAllSeriesDataValuesAsHabitValue();
          // }

          seriesData = SeriesData<HabitValue>(seriesDef.uuid, list);
          seriesData.sort();
          _uuid2seriesDataHabit[seriesDef.uuid] = seriesData;
        }
      case SeriesType.custom:
        var seriesData = _uuid2seriesDataCustom[seriesDef.uuid];
        if (seriesData == null) {
          var store = Stores.getOrCreateSeriesDataStore(seriesDef);
          var list = await store.getAllSeriesDataValuesAsCustomValue();

          seriesData = SeriesData<CustomValue>(seriesDef.uuid, list);
          seriesData.sort();
          _uuid2seriesDataCustom[seriesDef.uuid] = seriesData;
        }
    }
  }

  Future<void> delete(SeriesDef seriesDef, SeriesCurrentValueProvider seriesCurrentValueProvider) async {
    // delete current value
    await seriesCurrentValueProvider.delete(seriesDef);
    //  await Future.delayed(const Duration(seconds: 10)); // for testing

    await Stores.dropSeriesDataStore(seriesDef);

    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        _uuid2seriesDataBloodPressure.remove(seriesDef.uuid);
      case SeriesType.dailyCheck:
        _uuid2seriesDataDailyCheck.remove(seriesDef.uuid);
      case SeriesType.dailyLife:
        _uuid2seriesDataDailyLife.remove(seriesDef.uuid);
      case SeriesType.habit:
        _uuid2seriesDataHabit.remove(seriesDef.uuid);
      case SeriesType.custom:
        _uuid2seriesDataCustom.remove(seriesDef.uuid);
    }

    notifyListeners();
  }

  SeriesData? seriesData(SeriesDef seriesDef) {
    return switch (seriesDef.seriesType) {
      SeriesType.bloodPressure => bloodPressureData(seriesDef),
      SeriesType.dailyCheck => dailyCheckData(seriesDef),
      SeriesType.dailyLife => dailyLifeData(seriesDef),
      SeriesType.habit => habitData(seriesDef),
      SeriesType.custom => customData(seriesDef),
    };
  }

  SeriesData<BloodPressureValue>? bloodPressureData(SeriesDef seriesDef) {
    var seriesData = _uuid2seriesDataBloodPressure[seriesDef.uuid];
    return seriesData;
  }

  SeriesData<BloodPressureValue> requireBloodPressureData(SeriesDef seriesDef) {
    var seriesData = bloodPressureData(seriesDef);
    _checkOnSeriesData(seriesData, seriesDef);
    return seriesData!;
  }

  SeriesData<DailyCheckValue>? dailyCheckData(SeriesDef seriesDef) {
    var seriesData = _uuid2seriesDataDailyCheck[seriesDef.uuid];
    return seriesData;
  }

  SeriesData<DailyCheckValue> requireDailyCheckData(SeriesDef seriesDef) {
    var seriesData = dailyCheckData(seriesDef);
    _checkOnSeriesData(seriesData, seriesDef);
    return seriesData!;
  }

  SeriesData<DailyLifeValue>? dailyLifeData(SeriesDef seriesDef) {
    var seriesData = _uuid2seriesDataDailyLife[seriesDef.uuid];
    return seriesData;
  }

  SeriesData<DailyLifeValue> requireDailyLifeData(SeriesDef seriesDef) {
    var seriesData = dailyLifeData(seriesDef);
    _checkOnSeriesData(seriesData, seriesDef);
    return seriesData!;
  }

  SeriesData<HabitValue>? habitData(SeriesDef seriesDef) {
    var seriesData = _uuid2seriesDataHabit[seriesDef.uuid];
    return seriesData;
  }

  SeriesData<HabitValue> requireHabitData(SeriesDef seriesDef) {
    var seriesData = habitData(seriesDef);
    _checkOnSeriesData(seriesData, seriesDef);
    return seriesData!;
  }

  SeriesData<CustomValue>? customData(SeriesDef seriesDef) {
    var seriesData = _uuid2seriesDataCustom[seriesDef.uuid];
    return seriesData;
  }

  SeriesData<CustomValue> requireCustomData(SeriesDef seriesDef) {
    var seriesData = customData(seriesDef);
    _checkOnSeriesData(seriesData, seriesDef);
    return seriesData!;
  }

  Future<void> addValue(SeriesDef seriesDef, SeriesDataValue value, SeriesCurrentValueProvider seriesCurrentValueProvider) async {
    await _handleValue(seriesDef, value, _Action.insert, seriesCurrentValueProvider);
  }

  Future<void> updateValue(SeriesDef seriesDef, SeriesDataValue value, SeriesCurrentValueProvider seriesCurrentValueProvider) async {
    await _handleValue(seriesDef, value, _Action.update, seriesCurrentValueProvider);
  }

  Future<void> deleteValue(SeriesDef seriesDef, SeriesDataValue value, SeriesCurrentValueProvider seriesCurrentValueProvider) async {
    await _handleValue(seriesDef, value, _Action.delete, seriesCurrentValueProvider);
  }

  Future<void> _handleValue(SeriesDef seriesDef, SeriesDataValue value, _Action action, SeriesCurrentValueProvider seriesCurrentValueProvider) async {
    await fetchDataIfNotYetLoaded(seriesDef);
    var store = Stores.getOrCreateSeriesDataStore(seriesDef);

    SeriesData seriesData;

    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        BloodPressureValue.checkOnBloodPressureValue(value);
        seriesData = requireBloodPressureData(seriesDef);
      case SeriesType.dailyCheck:
        DailyCheckValue.checkOnDailyCheckValue(value);
        seriesData = requireDailyCheckData(seriesDef);
      case SeriesType.dailyLife:
        DailyLifeValue.checkOnDailyLifeValue(value);
        seriesData = requireDailyLifeData(seriesDef);
      case SeriesType.habit:
        HabitValue.checkOnHabitValue(value);
        seriesData = requireHabitData(seriesDef);
      case SeriesType.custom:
        CustomValue.checkOnCustomValue(value);
        seriesData = requireCustomData(seriesDef);
    }

    if (action == _Action.insert) {
      seriesData.insert(value);
      await store.save(value);
    } else if (action == _Action.update) {
      seriesData.update(value);
      await store.save(value);
    } else if (action == _Action.delete) {
      seriesData.delete(value);
      await store.delete(value);
    }
    seriesData.sort();

    // #45 always update currentValue with the last value
    if (seriesData.isEmpty()) {
      await seriesCurrentValueProvider.delete(seriesDef);
    } else {
      await seriesCurrentValueProvider.save(seriesDef, seriesData.data.last);
    }

    notifyListeners();
  }

  Future<void> addValues(SeriesDef seriesDef, List<dynamic> values, SeriesCurrentValueProvider seriesCurrentValueProvider) async {
    await fetchDataIfNotYetLoaded(seriesDef);
    SeriesData<SeriesDataValue> seriesData;
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        seriesData = requireBloodPressureData(seriesDef)..insertAll(values.map(BloodPressureValue.checkOnBloodPressureValue));
      case SeriesType.dailyCheck:
        seriesData = requireDailyCheckData(seriesDef)..insertAll(values.map(DailyCheckValue.checkOnDailyCheckValue));
      case SeriesType.dailyLife:
        seriesData = requireDailyLifeData(seriesDef)..insertAll(values.map(DailyLifeValue.checkOnDailyLifeValue));
      case SeriesType.habit:
        seriesData = requireHabitData(seriesDef)..insertAll(values.map(HabitValue.checkOnHabitValue));
      case SeriesType.custom:
        seriesData = requireCustomData(seriesDef)..insertAll(values.map(CustomValue.checkOnCustomValue));
    }

    seriesData.sort();

    var store = Stores.getOrCreateSeriesDataStore(seriesDef);
    await store.saveAll(seriesData.data);

    SeriesDataValue? latest = seriesData.data.lastOrNull;
    if (latest != null) await seriesCurrentValueProvider.save(seriesDef, latest);

    notifyListeners();
  }

  void _checkOnSeriesData(SeriesData? seriesData, SeriesDef seriesDef) {
    if (seriesData == null) {
      var errMsg = "Failed to create/load series data for ${seriesDef.name} (type: ${seriesDef.seriesType.typeName})!";
      SimpleLogging.w(errMsg);
      throw Ex(errMsg);
    }
  }
}

enum _Action {
  insert,
  update,
  delete;
}
