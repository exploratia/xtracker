import 'series_data_value.dart';

class SeriesData<T extends SeriesDataValue> {
  /// same as in SeriesDef
  final String uuid;

  final List<T> seriesItems;

  SeriesData(this.uuid, this.seriesItems);
}
