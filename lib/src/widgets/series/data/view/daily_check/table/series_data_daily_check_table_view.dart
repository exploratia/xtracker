import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profiles.dart';
import '../../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/globals.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import 'daily_check_values_renderer.dart';

class SeriesDataDailyCheckTableView extends StatelessWidget {
  final SeriesData<DailyCheckValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;

  /// Rows are always equal sized. But if set to false, multi line rows are inflated to multiple single line rows
  final bool _useEqualSizedRows = false;

  const SeriesDataDailyCheckTableView({super.key, required this.seriesViewMetaData, required this.seriesData});

  @override
  Widget build(BuildContext context) {
    // for daily check we need a special TableColumnProfile

    List<_DailyCheckDayItem> data = _buildTableDataProvider(seriesData);
    int lineHeight = 28;
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
      _DailyCheckDayItem dailyCheckDayItem = data[yIndex];

      if (xIndex == 0) {
        return GridCell(backgroundColor: dailyCheckDayItem.backgroundColor, child: Center(child: Text(dailyCheckDayItem.date)));
      }

      List<DailyCheckValue> dailyCheckValues;
      if (xIndex == 1) {
        dailyCheckValues = dailyCheckDayItem.morning;
      } else if (xIndex == 2) {
        dailyCheckValues = dailyCheckDayItem.midday;
      } else {
        dailyCheckValues = dailyCheckDayItem.evening;
      }
      return GridCell(
        backgroundColor: dailyCheckDayItem.backgroundColor,
        child: DailyCheckValuesRenderer(
          dailyCheckValues: dailyCheckValues,
          seriesViewMetaData: seriesViewMetaData,
        ),
      );
    }

    // padding because of headline in stack
    return Padding(
      padding: const EdgeInsets.only(top: ThemeUtils.seriesDataViewTopPadding),
      child: TwoDimensionalScrollableTable(
        tableColumnProfile: FixColumnProfiles.columnProfileDateMorningMiddayEvening,
        lineCount: data.length,
        gridCellBuilder: gridCellBuilder,
        lineHeight: lineHeight,
        useFixedFirstColumn: true,
      ),
    );
  }

  List<_DailyCheckDayItem> _buildTableDataProvider(SeriesData<DailyCheckValue> seriesData) {
    List<_DailyCheckDayItem> list = [];

    var emptyDate = '';
    add2List(List<_DailyCheckDayItem> list, _DailyCheckDayItem item) {
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

      List<_DailyCheckDayItem> inflated = [];
      for (var i = 0; i < maxItems; ++i) {
        // show date only on the first row
        var date = i == 0 ? item.date : emptyDate;
        inflated.add(_DailyCheckDayItem(date, item.backgroundColor));
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

    _DailyCheckDayItem? actItem;

    for (var item in seriesData.data.reversed) {
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
        actItem = _DailyCheckDayItem(dateDay, backgroundColor);
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

class _DailyCheckDayItem {
  final String date;
  final Color? backgroundColor;
  List<DailyCheckValue> morning = [];
  List<DailyCheckValue> midday = [];
  List<DailyCheckValue> evening = [];

  _DailyCheckDayItem(this.date, this.backgroundColor);
}
