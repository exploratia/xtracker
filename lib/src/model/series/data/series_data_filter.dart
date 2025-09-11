import '../../../util/date_time_utils.dart';
import 'series_data_value.dart';

class SeriesDataFilter {
  bool _dirty = false;
  DateTime? start;
  DateTime? end;

  bool filterDate(DateTime dateTime) {
    if (start != null && dateTime.isBefore(start!)) return false;
    if (end != null && dateTime.isAfter(end!)) return false;
    return true;
  }

  bool filter(SeriesDataValue value) {
    return filterDate(value.dateTime);
  }

  bool getAndResetDirty() {
    bool res = _dirty;
    _dirty = false;
    return res;
  }

  void setDate({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (start != startDate) {
      start = startDate;
      _dirty = true;
    }
    if (end != endDate) {
      end = endDate;
      _dirty = true;
    }
  }

  @override
  String toString() {
    String res = "";
    if (start != null && end != null) {
      res += "[${DateTimeUtils.formatYYYYMMDD(start!)} - ${DateTimeUtils.formatYYYYMMDD(end!)}]";
    } else if (start != null) {
      res += "[${DateTimeUtils.formatYYYYMMDD(start!)} - [";
    } else if (end != null) {
      res += "] - ${DateTimeUtils.formatYYYYMMDD(end!)}]";
    }
    return res;
  }
}
