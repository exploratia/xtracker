import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';

import '../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../model/series/data/series_data_value.dart';
import '../model/series/series_def.dart';
import '../model/series/series_type.dart';
import 'stores_utils.dart';

class StoreSeriesData {
  final String seriesDefUuid;
  final SeriesType seriesType;
  final StoreRef _store;
  final Database _db = StoresUtils.db;

  StoreSeriesData.fromSeriesDef({required SeriesDef seriesDef})
      : seriesDefUuid = seriesDef.uuid,
        seriesType = seriesDef.seriesType,
        _store = StoreRef<String, Map<String, dynamic>>('seriesData_${seriesDef.seriesType}_${seriesDef.uuid}');

  Future<void> save(SeriesDataValue seriesDataValue) async {
    await _store.record(seriesDataValue.uuid).put(_db, seriesDataValue.toJson());
  }

  Future<void> saveAll(List<SeriesDataValue> seriesDataValues) async {
    await _db.transaction(
      (transaction) async {
        for (var seriesDataValue in seriesDataValues) {
          await _store.record(seriesDataValue.uuid).put(transaction, seriesDataValue.toJson());
        }
      },
    );
  }

  Future<void> delete(SeriesDataValue seriesDataValue) async {
    await _store.record(seriesDataValue.uuid).delete(_db);
  }

  Future<void> dropStore() async {
    await _store.drop(_db);
  }

  Future<List<RecordSnapshot<Object?, Object?>>> _findAllSeriesDataValues() async {
    var records = await _store.find(_db, finder: Finder()); // find all
    if (kDebugMode) {
      print('Loaded SeriesDataValue count: ${records.length}');
    }
    return records;
  }

  /// returns unsorted list of SeriesDataValues
  Future<List<SeriesDataValue>> getAllSeriesDataValues() async {
    List<SeriesDataValue> result = [];
    List<RecordSnapshot<Object?, Object?>> records = await _findAllSeriesDataValues();
    for (var value in records.values) {
      result.add(SeriesDataValue.fromJson(value as Map<String, dynamic>, seriesType));
    }
    return result;
  }

  /// returns unsorted list of SeriesDataValues
  Future<List<BloodPressureValue>> getAllSeriesDataValuesAsBloodPressureValue() async {
    List<BloodPressureValue> result = [];
    List<RecordSnapshot<Object?, Object?>> records = await _findAllSeriesDataValues();
    for (var value in records.values) {
      result.add(BloodPressureValue.fromJson(value as Map<String, dynamic>));
    }
    return result;
  }
}
