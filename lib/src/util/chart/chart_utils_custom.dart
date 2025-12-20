import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/series/data/custom/custom_value.dart';
import '../../model/series/seriesItem/series_item.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_view_meta_data.dart';
import '../date_time_utils.dart';
import '../ex.dart';
import 'chart_utils_simple_value.dart';

class ChartUtilsCustom {
  static List<ParameterChartData> buildDataProviderPerParameter(SeriesViewMetaData seriesViewMetaData, List<CustomValue> seriesData) {
    Map<String, List<TimedValue>> siid2values = {};
    Map<String, bool> siid2useDelta = {};

    // first check if delta calculation is possible
    // if a parameter has no value... this check is not enough :/
    bool isDeltaPossible = seriesData.length > 1;

    for (var si in seriesViewMetaData.seriesDef.seriesItems.where((si) => !si.hideInChart)) {
      siid2values[si.siid] = [];
      siid2useDelta[si.siid] = isDeltaPossible && si.useDeltaInChart;
    }

    var siids = siid2values.keys;

    DateTime? prevTimestamp;
    for (final siid in siids) {
      double prevValue = 0;
      for (final dataItem in seriesData) {
        // check duplicate timestamps
        if (dataItem.dateTime == prevTimestamp) {
          throw Ex(
            "Found duplicate timestamp '$prevTimestamp' in custom data in series '${seriesViewMetaData.seriesDef.name}'!",
            localizedMessage: LocaleKeys.seriesData_monthly_msg_duplicateTimestamp.tr(
              args: ["${DateTimeUtils.formatDate(dataItem.dateTime)} ${DateTimeUtils.formatTime(dataItem.dateTime)}"],
            ),
          );
        }
        prevTimestamp = dataItem.dateTime;
        final v = dataItem.values[siid];
        if (v != null) {
          var val = v;
          if (siid2useDelta[siid] ?? false) {
            val = v - prevValue;
            // if val < 0 we had a reset...
            if (val < 0) val = v;
            prevValue = v;
          }

          siid2values[siid]!.add(
            TimedValue.value(dataItem.dateTime, val),
          );
        }
      }
    }

    List<ParameterChartData> result = [];
    for (var seriesItem in seriesViewMetaData.seriesDef.seriesItems.where((si) => !si.hideInChart)) {
      var data = siid2values[seriesItem.siid]!;
      // in case of delta ignore the first value (because it's absolute - there is no delta yet)
      // except there is only one value (if we hide it we see nothing...)
      if (data.length > 1 && (siid2useDelta[seriesItem.siid] ?? false)) {
        data.removeAt(0);
      }
      result.add(ParameterChartData(seriesDef: seriesViewMetaData.seriesDef, seriesItem: seriesItem, data: data));
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
