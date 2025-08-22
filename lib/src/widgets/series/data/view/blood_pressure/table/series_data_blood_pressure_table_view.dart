import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profiles.dart';
import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/globals.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../series_data_no_data.dart';
import 'blood_pressure_values_renderer.dart';

class SeriesDataBloodPressureTableView extends StatelessWidget {
  final List<BloodPressureValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;

  /// Rows are always equal sized. But if set to false, multi line rows are inflated to multiple single line rows
  final bool _useEqualSizedRows = false;

  const SeriesDataBloodPressureTableView({super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter});

  @override
  Widget build(BuildContext context) {
    // for blood pressure we need a special TableColumnProfile

    var filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
    if (filteredSeriesData.isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    List<_BloodPressureDayItem> data = _buildTableDataProvider(filteredSeriesData);
    int lineHeight = 30;
    if (_useEqualSizedRows) {
      // calc line height = single line height * max lines per day of all items
      var maxItemsPerDayPart = data.fold(
        1,
        (previousValue, item) {
          var maxItems = math.max(math.max(item.morning.length, item.midday.length), item.evening.length);
          return math.max(previousValue, maxItems);
        },
      );
      lineHeight *= maxItemsPerDayPart;
    }

    gridCellBuilder(BuildContext context, int yIndex, int xIndex) {
      _BloodPressureDayItem bloodPressureDayItem = data[yIndex];

      if (xIndex == 0) {
        return GridCell(backgroundColor: bloodPressureDayItem.backgroundColor, child: Center(child: Text(bloodPressureDayItem.date)));
      }

      List<BloodPressureValue> bloodPressureValues;
      if (xIndex == 1) {
        bloodPressureValues = bloodPressureDayItem.morning;
      } else if (xIndex == 2) {
        bloodPressureValues = bloodPressureDayItem.midday;
      } else {
        bloodPressureValues = bloodPressureDayItem.evening;
      }
      return GridCell(
        backgroundColor: bloodPressureDayItem.backgroundColor,
        child: BloodPressureValuesRenderer(
          bloodPressureValues: bloodPressureValues,
          seriesViewMetaData: seriesViewMetaData,
          showBorder: true,
        ),
      );
    }

    return TwoDimensionalScrollableTable(
      tableColumnProfile: FixColumnProfiles.columnProfileDateMorningMiddayEvening,
      lineCount: data.length,
      gridCellBuilder: gridCellBuilder,
      lineHeight: lineHeight,
      useFixedFirstColumn: true,
      bottomScrollExtend: ThemeUtils.seriesDataBottomFilterViewHeight,
    );
  }

  List<_BloodPressureDayItem> _buildTableDataProvider(List<BloodPressureValue> seriesData) {
    List<_BloodPressureDayItem> list = [];

    var emptyDate = '';
    add2List(List<_BloodPressureDayItem> list, _BloodPressureDayItem item) {
      if (_useEqualSizedRows) {
        list.add(item);
        return;
      }

      // use multiple rows for a single day if more than 1 element in one of the lists
      var maxItems = math.max(math.max(item.morning.length, item.midday.length), item.evening.length);
      if (maxItems == 1) {
        list.add(item);
        return;
      }

      List<_BloodPressureDayItem> inflated = [];
      for (var i = 0; i < maxItems; ++i) {
        // show date only on the first row
        var date = i == 0 ? item.date : emptyDate;
        inflated.add(_BloodPressureDayItem(date, item.backgroundColor));
      }
      for (var i = 0; i < item.morning.length; ++i) {
        inflated[i].morning.add(item.morning[i]);
      }
      for (var i = 0; i < item.midday.length; ++i) {
        inflated[i].midday.add(item.midday[i]);
      }
      for (var i = 0; i < item.evening.length; ++i) {
        inflated[i].evening.add(item.evening[i]);
      }

      list.addAll(inflated);
    }

    _BloodPressureDayItem? actItem;

    for (var item in seriesData.reversed) {
      String dateDay = DateTimeUtils.formateDate(item.dateTime);
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
        actItem = _BloodPressureDayItem(dateDay, backgroundColor);
      }

      if (item.dateTime.hour < 10) {
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

class _BloodPressureDayItem {
  final String date;
  final Color? backgroundColor;
  List<BloodPressureValue> morning = [];
  List<BloodPressureValue> midday = [];
  List<BloodPressureValue> evening = [];

  _BloodPressureDayItem(this.date, this.backgroundColor);
}
