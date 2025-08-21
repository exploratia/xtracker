import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profiles.dart';
import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/globals.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import 'habit_values_renderer.dart';

class SeriesDataHabitTableView extends StatelessWidget {
  final List<HabitValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;

  /// Rows are always equal sized. But if set to false, multi line rows are inflated to multiple single line rows
  final bool _useEqualSizedRows = false;

  const SeriesDataHabitTableView({super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter});

  @override
  Widget build(BuildContext context) {
    // for daily check we need a special TableColumnProfile

    List<_HabitDayItem> data = _buildTableDataProvider(seriesData.where((value) => seriesDataFilter.filter(value)).toList());
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
      _HabitDayItem habitDayItem = data[yIndex];

      if (xIndex == 0) {
        return GridCell(backgroundColor: habitDayItem.backgroundColor, child: Center(child: Text(habitDayItem.date)));
      }

      List<HabitValue> habitValues;
      if (xIndex == 1) {
        habitValues = habitDayItem.morning;
      } else if (xIndex == 2) {
        habitValues = habitDayItem.midday;
      } else {
        habitValues = habitDayItem.evening;
      }
      return GridCell(
        backgroundColor: habitDayItem.backgroundColor,
        child: HabitValuesRenderer(
          habitValues: habitValues,
          seriesViewMetaData: seriesViewMetaData,
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

  List<_HabitDayItem> _buildTableDataProvider(List<HabitValue> seriesData) {
    List<_HabitDayItem> list = [];

    var emptyDate = '';
    add2List(List<_HabitDayItem> list, _HabitDayItem item) {
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

      List<_HabitDayItem> inflated = [];
      for (var i = 0; i < maxItems; ++i) {
        // show date only on the first row
        var date = i == 0 ? item.date : emptyDate;
        inflated.add(_HabitDayItem(date, item.backgroundColor));
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

    _HabitDayItem? actItem;

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
        actItem = _HabitDayItem(dateDay, backgroundColor);
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

class _HabitDayItem {
  final String date;
  final Color? backgroundColor;
  List<HabitValue> morning = [];
  List<HabitValue> midday = [];
  List<HabitValue> evening = [];

  _HabitDayItem(this.date, this.backgroundColor);
}
