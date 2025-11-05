import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../util/color_utils.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/globals.dart';
import '../../../../util/theme_utils.dart';

class SeriesDataValueGridItem<V extends SeriesDataValue> {
  final SeriesDef seriesDef;
  final V value;
  final String? date;
  final String? time;
  late Color? backgroundColor;

  SeriesDataValueGridItem(this.seriesDef, this.value, this.date, this.time) {
    if (seriesDef.seriesType == SeriesType.monthly) {
      backgroundColor = (value.dateTime.month % 2 == 0) ? Globals.backgroundColorSaturday : null;
    } else {
      backgroundColor = ColorUtils.weekdayBackgroundColor(value.dateTime);
    }
  }

  static List<SeriesDataValueGridItem<T>> buildTableDataProvider<T extends SeriesDataValue>(
      SeriesViewMetaData seriesViewMetaData, List<T> seriesData, BuildContext context) {
    var seriesDef = seriesViewMetaData.seriesDef;
    var monthly = seriesDef.seriesType == SeriesType.monthly;

    Set<String> dates = {};
    Set<String> duplicateDates = {};

    List<SeriesDataValueGridItem<T>> list = [];
    String prevDate = "";
    for (var sd in seriesData.reversed) {
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

      SeriesDataValueGridItem<T> seriesDataValueGridItem;
      if (prevDate == date) {
        seriesDataValueGridItem = SeriesDataValueGridItem(seriesDef, sd, null, time);
      } else {
        seriesDataValueGridItem = SeriesDataValueGridItem(seriesDef, sd, date, time);
        prevDate = date;
      }
      list.add(seriesDataValueGridItem);

      // check for duplicates
      var dt = '$date  ${time ?? ''}'.trim();
      if (!dates.add(dt)) {
        seriesDataValueGridItem.backgroundColor = ThemeUtils.errorColor.withAlpha(96);
        duplicateDates.add(dt);
      }
    }

    if (duplicateDates.isNotEmpty && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Dialogs.showSnackBarWarning(LocaleKeys.seriesData_snackbar_duplicateDates.tr(args: [duplicateDates.join(", ")]), context,
            duration: const Duration(seconds: 3));
      });
    }

    return list;
  }
}
