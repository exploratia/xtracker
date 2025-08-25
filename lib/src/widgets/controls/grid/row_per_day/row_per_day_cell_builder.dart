import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data_value.dart';
import '../../../../util/date_time_utils.dart';
import '../two_dimensional_scrollable_table.dart';
import 'day_row_item.dart';

class RowPerDayCellBuilder<T extends SeriesDataValue> {
  final List<DayRowItem<T>> data;
  final Widget Function(T value) gridCellChildBuilder;
  final bool useDateTimeValueColumnProfile;

  RowPerDayCellBuilder({required this.data, required this.gridCellChildBuilder, required this.useDateTimeValueColumnProfile});

  GridCell gridCellBuilder(BuildContext context, int yIndex, int xIndex) {
    DayRowItem<T> dayItem = data[yIndex];

    if (xIndex == 0) {
      return GridCell(backgroundColor: dayItem.backgroundColor, child: Center(child: Text(dayItem.date)));
    }

    T? value;

    if (useDateTimeValueColumnProfile) {
      Widget gridCellChild = Container();
      value = dayItem.all;
      if (xIndex == 1 && value != null) {
        gridCellChild = Center(child: Text(DateTimeUtils.formateTime(value.dateTime)));
      } else if (xIndex == 2 && value != null) {
        gridCellChild = gridCellChildBuilder(value);
      }

      return GridCell(backgroundColor: dayItem.backgroundColor, child: gridCellChild);
    }

    if (xIndex == 1) {
      value = dayItem.morning;
    } else if (xIndex == 2) {
      value = dayItem.midday;
    } else {
      value = dayItem.evening;
    }

    Widget gridCellChild = Container();
    if (value != null) {
      gridCellChild = gridCellChildBuilder(value);
    }
    return GridCell(
      backgroundColor: dayItem.backgroundColor,
      child: gridCellChild,
    );
  }
}
