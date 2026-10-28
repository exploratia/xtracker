import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/series/data/custom/custom_value.dart';
import '../../model/series/seriesItem/series_item.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_view_meta_data.dart';
import '../date_time_utils.dart';
import '../ex.dart';
import 'chart_delta_filter.dart';
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

    for (final siid in siids) {
      DateTime? prevTimestamp;
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
        if (v == null || v.isNaN || v.isInfinite) {
          continue;
        }
        siid2values[siid]!.add(
          TimedValue.value(dataItem.dateTime, v),
        );
      }
    }

    List<ParameterChartData> result = [];
    for (var seriesItem in seriesViewMetaData.seriesDef.seriesItems.where((si) => !si.hideInChart)) {
      var data = siid2values[seriesItem.siid]!;
      if (data.length > 1 && (siid2useDelta[seriesItem.siid] ?? false)) {
        data = ChartDeltaFilter.buildDeltas(data, filterOutliers: seriesItem.filterDeltaOutliersInChart);
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
