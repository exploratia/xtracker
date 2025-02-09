import 'package:flutter/material.dart';

import '../model/series/series_def.dart';

class SeriesProvider with ChangeNotifier {
  List<SeriesDef>? _series;

  Future<void> fetchDataIfNotYetLoaded() async {
    if (_series == null) {
      await fetchData();
    }
    notifyListeners();
  }

  Future<void> fetchData() async {
    await _get();
    notifyListeners();
  }

  Future<void> _get() async {
    // TODO load from files
    print('TODO get from files');
    _series ??= [];
    return;
  }

  Future<void> _post(SeriesDef seriesDef) async {
    //  await Future.delayed(const Duration(seconds: 10)); // for testing
// TODO save to file
    // at the moment add directly to _series
    _series ??= [];
    _series!.add(seriesDef);
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
}
