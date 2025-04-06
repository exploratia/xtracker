import '../model/series/series_def.dart';
import 'store_main.dart';
import 'store_series_current_value.dart';
import 'store_series_data.dart';
import 'store_series_def.dart';

class Stores {
  static final StoreMain storeMain = StoreMain();
  static final StoreSeriesDef storeSeriesDef = StoreSeriesDef();
  static final StoreSeriesCurrentValue storeSeriesCurrentValue = StoreSeriesCurrentValue();
  static final Map<String, StoreSeriesData> _storeSeriesData = {};

  static StoreSeriesData getOrCreateSeriesDataStore(SeriesDef seriesDef) {
    StoreSeriesData? store = _storeSeriesData[seriesDef.uuid];
    if (store != null) return store;

    store = StoreSeriesData.fromSeriesDef(seriesDef: seriesDef);
    _storeSeriesData[seriesDef.uuid] = store;
    return store;
  }

  static Future<void> dropSeriesDataStore(SeriesDef seriesDef) async {
    StoreSeriesData store = getOrCreateSeriesDataStore(seriesDef);
    _storeSeriesData.remove(seriesDef.uuid);
    await store.dropStore();
  }
}
