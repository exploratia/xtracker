import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';

import '../model/series/current_value/series_current_value.dart';
import 'stores_utils.dart';

// https://github.com/tekartik/sembast.dart/blob/master/sembast/doc/queries.md
class StoreSeriesCurrentValue {
  final StoreRef _store = StoreRef<String, Map<String, dynamic>>('seriesCurrentValue');
  final Database _db = StoresUtils.db;

  Future<void> save(SeriesCurrentValue seriesCurrentValue) async {
    await _store.record(seriesCurrentValue.seriesDefUuid).put(_db, seriesCurrentValue.toJson());
  }

  Future<void> delete(String seriesDefUuid) async {
    await _store.record(seriesDefUuid).delete(_db);
  }

  Future<List<SeriesCurrentValue>> getAllCurrentValues() async {
    List<SeriesCurrentValue> result = [];
    var records = await _store.find(_db, finder: Finder()); // find all
    if (kDebugMode) {
      print('Loaded SeriesCurrentValue count: ${records.length}');
    }
    for (var value in records.values) {
      result.add(SeriesCurrentValue.fromJson(value as Map<String, dynamic>));
    }
    return result;
  }
}
