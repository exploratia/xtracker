import 'dart:math';

import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/series/data/monthly/monthly_value.dart';
import '../../model/series/seriesItem/series_item.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_view_meta_data.dart';
import '../date_time_utils.dart';
import '../ex.dart';
import 'chart_utils_simple_value.dart';

class ChartUtilsMonthly {
  static List<ParameterChartData> buildDataProviderPerParameter(SeriesViewMetaData seriesViewMetaData, List<MonthlyValue> seriesData) {
    Map<String, List<TimedValue>> siid2values = {};
    for (var e in seriesViewMetaData.seriesDef.seriesItems) {
      siid2values[e.siid] = [];
    }

    var siids = siid2values.keys;

    if (seriesViewMetaData.showCompressed) {
      // compress yearly
      Map<String, TimedValue> siid2actValue = {};

      for (final dataItem in seriesData) {
        var ts = DateTimeUtils.firstDayOfYear(dataItem.dateTime);
        // check duplicate timestamps for monthly
        for (final key in siids) {
          final v = dataItem.values[key];
          if (v != null) {
            var actValue = siid2actValue[key];
            if (actValue == null) {
              siid2actValue[key] = TimedValue.value(ts, v);
            } else {
              // same timestamp -> update
              if (actValue.dateTime == ts) {
                actValue.add(v);
              }
              // otherwise store so far and create new
              else {
                siid2values[key]!.add(actValue);
                siid2actValue[key] = TimedValue.value(ts, v);
              }
            }
          }
        }
      }

      // add not yet added to lists
      for (var entry in siid2actValue.entries) {
        siid2values[entry.key]!.add(entry.value);
      }
    } else {
      DateTime? prevTimestamp;
      for (final dataItem in seriesData) {
        // check duplicate timestamps for monthly
        if (dataItem.dateTime == prevTimestamp) {
          throw Ex(
            "Found duplicate timestamp '$prevTimestamp' in monthly data in series '${seriesViewMetaData.seriesDef.name}'!",
            localizedMessage: LocaleKeys.seriesData_monthly_msg_duplicateTimestamp.tr(args: [DateTimeUtils.formatMonthYear(dataItem.dateTime)]),
          );
        }
        prevTimestamp = dataItem.dateTime;
        for (final key in siids) {
          final v = dataItem.values[key];
          if (v != null) {
            siid2values[key]!.add(
              TimedValue.value(dataItem.dateTime, v),
            );
          }
        }
      }
    }

    List<ParameterChartData> result = [];
    for (var seriesItem in seriesViewMetaData.seriesDef.seriesItems.where((si) => !si.hideInChart)) {
      result.add(ParameterChartData(seriesDef: seriesViewMetaData.seriesDef, seriesItem: seriesItem, data: siid2values[seriesItem.siid]!));
    }
    return result;
  }
}

class ParameterChartData {
  final SeriesDef seriesDef;
  final SeriesItem seriesItem;
  final List<TimedValue> data;

  ParameterChartData({required this.seriesDef, required this.seriesItem, required this.data});
}
