import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../model/series/series_def.dart';
import '../model/series/series_type.dart';
import '../store/stores.dart';
import 'series_current_value_provider.dart';
import 'series_data_provider.dart';

class SeriesProvider with ChangeNotifier {
  final _storeMain = Stores.storeMain;
  final _storeSeriesDef = Stores.storeSeriesDef;
  List<SeriesDef> _series = [];
  bool _seriesLoaded = false;

  Future<void> fetchDataIfNotYetLoaded() async {
    if (!_seriesLoaded) {
      await fetchData();
    }
  }

  Future<void> fetchData() async {
    // await Future.delayed(const Duration(seconds: 10)); // for testing

    _series = await _storeSeriesDef.getAllSeries();

    // TODO only for testing - remove it
    if (_series.isEmpty) {
      await _storeSeriesDef.save(SeriesDef(
        uuid: const Uuid().v4().toString(),
        seriesType: SeriesType.bloodPressure,
        color: Colors.green,
        name: "1 mit sehr sehr sehr sehr sehr sehr viel sehr sehr sehr sehr sehr sehr und noch Mehr sehr sehr sehr sehr sehr sehr viel Text",
        seriesItems: SeriesItem.bloodPressureSeriesItems(),
      ));

      await _storeSeriesDef.save(SeriesDef(
        uuid: const Uuid().v4().toString(),
        seriesType: SeriesType.bloodPressure,
        name: '2',
        seriesItems: SeriesItem.bloodPressureSeriesItems(),
      ));

      await _storeSeriesDef.save(SeriesDef(
        uuid: const Uuid().v4().toString(),
        seriesType: SeriesType.dailyCheck,
        name: '3',
        seriesItems: [],
      ));

      _series = await _storeSeriesDef.getAllSeries();
    }

    List<String> orderedSeriesUuids = await _storeMain.loadSeriesOrder();

    _sortSeries(orderedSeriesUuids);

    _seriesLoaded = true;
    notifyListeners();
  }

  List<SeriesDef> get series {
    return [..._series];
  }

  SeriesDef? getSeries(String seriesUuid) {
    return series.firstWhere((s) => s.uuid == seriesUuid);
  }

  Future<void> save(SeriesDef seriesDef) async {
    //  await Future.delayed(const Duration(seconds: 10)); // for testing
    await _storeSeriesDef.save(seriesDef);
    await fetchData();
    // notifyListeners(); notify is in fetch
  }

  Future<void> deleteById(String seriesDefUuid, BuildContext context) async {
    var idx = _series.indexWhere((s) => s.uuid == seriesDefUuid);
    if (idx < 0) return;
    await delete(_series.removeAt(idx), context);
  }

  Future<void> delete(SeriesDef seriesDef, BuildContext context) async {
    SeriesCurrentValueProvider seriesCurrentValueProvider = context.read<SeriesCurrentValueProvider>();
    SeriesDataProvider seriesDataProvider = context.read<SeriesDataProvider>();

    // delete current value
    await seriesCurrentValueProvider.delete(seriesDef);

    // delete series data
    if (context.mounted) {
      await seriesDataProvider.delete(seriesDef, context);
    }

    await _storeSeriesDef.delete(seriesDef);
    await fetchData();
    // notifyListeners(); notify is in fetch
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (_series.length <= oldIndex || _series.length <= newIndex) return;
    var seriesUuids = [..._series.map((e) => e.uuid)];

    final item = seriesUuids.removeAt(oldIndex);
    seriesUuids.insert(newIndex, item);

    await _storeMain.saveSeriesOrder(seriesUuids);

    _sortSeries(seriesUuids);

    notifyListeners();
  }

  void _sortSeries(List<String> orderedSeriesUuids) {
    if (orderedSeriesUuids.isEmpty) return;
    _series.sort((a, b) {
      int indexA = orderedSeriesUuids.indexOf(a.uuid);
      int indexB = orderedSeriesUuids.indexOf(b.uuid);

      // Falls die UUID nicht in der zweiten Liste ist, setzen wir einen großen Index-Wert
      if (indexA == -1) indexA = orderedSeriesUuids.length;
      if (indexB == -1) indexB = orderedSeriesUuids.length;

      return indexA.compareTo(indexB);
    });
  }
}
