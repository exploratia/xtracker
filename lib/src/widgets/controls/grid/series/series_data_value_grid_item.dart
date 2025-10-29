import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../util/color_utils.dart';
import '../../../../util/date_time_utils.dart';

class SeriesDataValueGridItem<V extends SeriesDataValue> {
  final SeriesDef seriesDef;
  final V value;
  final String? date;
  final String? time;
  late final Color? backgroundColor;

  SeriesDataValueGridItem(this.seriesDef, this.value, this.date, this.time) {
    backgroundColor = ColorUtils.weekdayBackgroundColor(value.dateTime);
  }

  static List<SeriesDataValueGridItem<T>> buildTableDataProvider<T extends SeriesDataValue>(SeriesViewMetaData seriesViewMetaData, List<T> seriesData) {
    var seriesDef = seriesViewMetaData.seriesDef;
    var monthly = seriesDef.seriesType == SeriesType.monthly;

    List<SeriesDataValueGridItem<T>> list = [];
    String prevDate = "";
    for (var sd in seriesData) {
      String? time = DateTimeUtils.formatTime(sd.dateTime);

      String date = "";
      if (monthly) {
        date = DateTimeUtils.formatMonthYear(sd.dateTime);
        // in case of monthly no time (always 0:00)
        // there shouldn't be 2 lines with the same date either.
        time = null;
      } else {
        date = DateTimeUtils.formatDate(sd.dateTime);
      }
      if (prevDate == date) {
        list.add(SeriesDataValueGridItem(seriesDef, sd, null, time));
      } else {
        list.add(SeriesDataValueGridItem(seriesDef, sd, date, time));
        prevDate = date;
      }
    }

    return list;
  }
}
