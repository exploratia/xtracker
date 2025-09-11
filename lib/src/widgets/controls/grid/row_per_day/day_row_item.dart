import 'dart:math' as math;
import 'dart:ui';

import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/globals.dart';

class DayRowItem<T extends SeriesDataValue> {
  final String date;
  final Color? backgroundColor;
  T? all;
  T? morning;
  T? midday;
  T? evening;

  DayRowItem(this.date, this.backgroundColor);

  static List<DayRowItem<T>> buildTableDataProvider<T extends SeriesDataValue>(SeriesViewMetaData seriesViewMetaData, List<T> seriesData) {
    bool useDateTimeValueColumnProfile = seriesViewMetaData.seriesDef.displaySettingsReadonly().tableViewUseColumnProfileDateTimeValue;
    List<DayRowItem<T>> list = [];

    var emptyDate = '';
    add2List(List<DayRowItem<T>> list, _DayMultiRowItem<T> item) {
      // use multiple rows for a single day if more than 1 element in one of the lists
      List<DayRowItem<T>> inflated = [];
      var maxItems = [item.all.length, item.morning.length, item.midday.length, item.evening.length].reduce(math.max);
      for (var i = 0; i < maxItems; ++i) {
        // show date only on the first row
        var date = i == 0 ? item.date : emptyDate;
        inflated.add(DayRowItem<T>(date, item.backgroundColor));
      }
      for (var i = 0; i < item.all.length; ++i) {
        inflated[i].all = item.all[i];
      }
      for (var i = 0; i < item.morning.length; ++i) {
        inflated[i].morning = item.morning[i];
      }
      for (var i = 0; i < item.midday.length; ++i) {
        inflated[i].midday = item.midday[i];
      }
      for (var i = 0; i < item.evening.length; ++i) {
        inflated[i].evening = item.evening[i];
      }

      list.addAll(inflated);
    }

    _DayMultiRowItem<T>? actItem;

    for (var item in seriesData.reversed) {
      String dateDay = DateTimeUtils.formatDate(item.dateTime);
      if (actItem == null || actItem.date != dateDay) {
        if (actItem != null) {
          add2List(list, actItem);
        }
        Color? backgroundColor;
        if (item.dateTime.weekday == DateTime.sunday) {
          backgroundColor = Globals.backgroundColorSunday;
        } else if (item.dateTime.weekday == DateTime.saturday) {
          backgroundColor = Globals.backgroundColorSaturday;
        }
        actItem = _DayMultiRowItem<T>(dateDay, backgroundColor);
      }

      if (useDateTimeValueColumnProfile) {
        actItem.all.add(item);
      } else if (item.dateTime.hour < 10) {
        actItem.morning.add(item);
      } else if (item.dateTime.hour > 16) {
        actItem.evening.add(item);
      } else {
        actItem.midday.add(item);
      }
    }

    // add last item to list
    if (actItem != null) {
      add2List(list, actItem);
    }

    return list;
  }
}

class _DayMultiRowItem<T extends SeriesDataValue> {
  final String date;
  final Color? backgroundColor;
  final List<T> all = [];
  final List<T> morning = [];
  final List<T> midday = [];
  final List<T> evening = [];

  _DayMultiRowItem(this.date, this.backgroundColor);
}
