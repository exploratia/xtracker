import 'series_data_value.dart';

class SeriesDataFilter {
  DateTime? start;
  DateTime? end;

  bool filterDate(DateTime dateTime) {
    if (start != null && dateTime.isBefore(start!)) return false;
    if (end != null && !dateTime.isBefore(end!)) return false;
    return true;
  }

  bool filter(SeriesDataValue value) {
    return filterDate(value.dateTime);
  }

  @override
  String toString() {
    return 'SeriesDataFilter{start: $start, end: $end}';
  }
}
