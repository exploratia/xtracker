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
    SimpleLogging.i("loaded series records: ${records.length}");
    for (var value in records.values) {
      try {
        var seriesDef = SeriesDef.fromJson(value as Map<String, dynamic>);
        SimpleLogging.i("Instantiated series: ${seriesDef.name} (${seriesDef.seriesType})");
        result.add(seriesDef);
      } catch (err) {
        SimpleLogging.w("Failed to instantiate series! $value", error: err);
      }
    }
    SimpleLogging.i("loaded series: done");

    if (records.isNotEmpty) {
      result.sort((a, b) => a.name.compareTo(b.name));
      var logSeries = result.map((e) => e.toLogString()).reduce((value, element) => '$value,${SimpleLogging.nl}$element');
      SimpleLogging.i('Successfully loaded ${result.length} series:${SimpleLogging.nl}$logSeries');
    }
    return result;
  }
}
