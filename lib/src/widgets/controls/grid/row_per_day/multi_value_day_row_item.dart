import 'dart:ui';

import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/globals.dart';

class MultiValueDayRowItem<T extends SeriesDataValue> {
  final String date;
  final Color? backgroundColor;
  final List<T> values = [];
  List<int> _hourlyValues = [];

  MultiValueDayRowItem(this.date, this.backgroundColor);

  /// returns the number of values
  int get count {
    return values.length;
  }

  DateTime get minDateTime {
    var c = count;
    if (c == 0) return DateTime(0);
    if (c == 1) return values.first.datetime;

    return DateTimeUtils.minDate(values.first.datetime, values.last.datetime);
  }

  DateTime get maxDateTime {
    var c = count;
    if (c == 0) return DateTime(0);
    if (c == 1) return values.first.datetime;

    return DateTimeUtils.maxDate(values.first.datetime, values.last.datetime);
  }

  List<int> countPerHour() {
    if (_hourlyValues.isEmpty) {
      _hourlyValues = List.generate(24, (index) => 0);
      for (var value in values) {
        _hourlyValues[value.datetime.hour]++;
      }
    }
    return _hourlyValues;
  }

  static List<MultiValueDayRowItem<T>> buildTableDataProvider<T extends SeriesDataValue>(SeriesViewMetaData seriesViewMetaData, List<T> seriesData) {
    List<MultiValueDayRowItem<T>> list = [];

    MultiValueDayRowItem<T>? actItem;

    for (var item in seriesData.reversed) {
      String dateDay = DateTimeUtils.formatDate(item.dateTime);
      if (actItem == null || actItem.date != dateDay) {
        if (actItem != null) {
          list.add(actItem);
        }
        Color? backgroundColor;
        if (item.dateTime.weekday == DateTime.sunday) {
          backgroundColor = Globals.backgroundColorSunday;
        } else if (item.dateTime.weekday == DateTime.saturday) {
          backgroundColor = Globals.backgroundColorSaturday;
        }
        actItem = MultiValueDayRowItem<T>(dateDay, backgroundColor);
      }

      actItem.values.add(item);
    }

    // add last item to list
    if (actItem != null) {
      list.add(actItem);
    }

    return list;
  }
}
