import '../../../../model/series/data/series_data_value.dart';

class InputResult<T extends SeriesDataValue> {
  final T seriesDataValue;
  final InputResultAction action;

  InputResult(this.seriesDataValue, this.action);
}

enum InputResultAction { insert, update, delete }
