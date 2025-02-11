import 'package:flutter/material.dart';

import '../model/series/series_def.dart';

class SeriesProvider with ChangeNotifier {
  List<SeriesDef>? _series;

  Future<void> fetchDataIfNotYetLoaded() async {
    if (_series == null) {
      await fetchData();
      notifyListeners();
    }
  }

  Future<void> fetchData() async {
    await _get();
    notifyListeners();
  }

  Future<void> _get() async {
    // TODO load from files
    print('TODO get from files');
    _series ??= [];
    // todo sort by phone storage order
    return;
  }

  Future<void> _post(SeriesDef seriesDef) async {
    //  await Future.delayed(const Duration(seconds: 10)); // for testing
// TODO save to file
    // at the moment add directly to _series
    _series ??= [];
    _series!.add(seriesDef);
  }

  Future<void> _del(SeriesDef seriesDef) async {
    //  await Future.delayed(const Duration(seconds: 10)); // for testing
// TODO save to file
    // TODO remove from phone storage order
    // at the moment add directly to _series
    _series ??= [];
    _series!.remove(seriesDef);
  }

  List<SeriesDef> get series {
    if (_series == null) return [];
    return [..._series!];
  }

  Future<void> add(SeriesDef seriesDef) async {
    await _post(seriesDef);
    await fetchData();
    notifyListeners();
  }

  Future<void> remove(SeriesDef seriesDef) async {
    await _del(seriesDef);
    await fetchData();
    notifyListeners();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    _series ??= [];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (_series!.length <= oldIndex || _series!.length <= newIndex) return;
    final SeriesDef? item = _series?.removeAt(oldIndex);
    if (item != null) {
      _series?.insert(newIndex, item);
    }
    // TODO save order in phone storage

    notifyListeners();
  }
}
