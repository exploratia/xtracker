import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'series_current_value_provider.dart';
import 'series_data_provider.dart';
import 'series_provider.dart';

class SeriesProviders {
  final SeriesProvider seriesProvider;

  final SeriesDataProvider seriesDataProvider;

  final SeriesCurrentValueProvider seriesCurrentValueProvider;

  SeriesProviders(this.seriesProvider, this.seriesDataProvider, this.seriesCurrentValueProvider);

  static SeriesProviders readOf(BuildContext context) {
    SeriesProvider seriesProvider = context.read<SeriesProvider>();
    SeriesDataProvider seriesDataProvider = context.read<SeriesDataProvider>();
    SeriesCurrentValueProvider seriesCurrentValueProvider = context.read<SeriesCurrentValueProvider>();
    return SeriesProviders(seriesProvider, seriesDataProvider, seriesCurrentValueProvider);
  }
}
