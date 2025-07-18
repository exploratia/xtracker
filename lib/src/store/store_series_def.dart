import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';

import '../model/series/series_def.dart';
import '../util/logging/flutter_simple_logging.dart';
import 'stores.dart';
import 'stores_utils.dart';

// https://github.com/tekartik/sembast.dart/blob/master/sembast/doc/queries.md
class StoreSeriesDef {
  final StoreRef _store = StoreRef<String, Map<String, dynamic>>('seriesDef');
  final Database _db = StoresUtils.db;

  Future<void> save(SeriesDef seriesDef) async {
    await _store.record(seriesDef.uuid).put(_db, seriesDef.toJson());
    SimpleLogging.i('Stored ${seriesDef.toLogString()}');
    Stores.getOrCreateSeriesDataStore(seriesDef);
  }

  Future<void> delete(SeriesDef seriesDef) async {
    await _store.record(seriesDef.uuid).delete(_db);
    SimpleLogging.i('Deleted ${seriesDef.toLogString()}');
  }

  Future<List<SeriesDef>> getAllSeries() async {
    List<SeriesDef> result = [];
    var records = await _store.find(_db, finder: Finder()); // find all
    if (kDebugMode) {
      print('Loaded SeriesDef count: ${records.length}');
    }
    for (var value in records.values) {
      result.add(SeriesDef.fromJson(value as Map<String, dynamic>));
    }

    if (records.isNotEmpty) {
      result.sort((a, b) => a.name.compareTo(b.name));
      var logSeries = result.map((e) => e.toLogString()).reduce((value, element) => '$value,${SimpleLogging.nl}$element');
      SimpleLogging.i('Successfully loaded ${records.length} series:${SimpleLogging.nl}$logSeries');
    }
    return result;
  }
}
