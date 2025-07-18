import 'package:sembast/sembast.dart';

import 'stores_utils.dart';

// https://github.com/tekartik/sembast.dart/blob/master/sembast/doc/queries.md
class StoreMain {
  final StoreRef _store = StoreRef.main();
  final Database _db = StoresUtils.db;

  static const _keySeriesOrder = 'seriesOrder';

  Future<void> saveSeriesOrder(List<String> seriesUuids) async {
    await _store.record(_keySeriesOrder).put(_db, seriesUuids);
  }

  Future<List<String>> loadSeriesOrder() async {
    List<String> result = [];
    var value = await _store.record(_keySeriesOrder).get(_db);
    if (value != null && value is List) {
      for (var o in value) {
        result.add(o.toString());
      }
    }
    return result;
  }
}
