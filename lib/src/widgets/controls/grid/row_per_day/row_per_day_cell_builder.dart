import 'package:flutter/material.dart';

import '../../../../model/column_profile/fix_column_profile.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/logging/flutter_simple_logging.dart';
import '../two_dimensional_scrollable_table.dart';
import 'day_row_item.dart';

class RowPerDayCellBuilder<T extends SeriesDataValue> {
  final List<DayRowItem<T>> data;
  final Widget Function(T value, Size cellSize) gridCellChildBuilder;
  final FixColumnProfile fixColumnProfile;

  RowPerDayCellBuilder({required this.data, required this.gridCellChildBuilder, required this.fixColumnProfile});

  GridCell gridCellBuilder(BuildContext context, int yIndex, int xIndex, Size cellSize) {
    DayRowItem<T> dayItem = data[yIndex];

    if (xIndex == 0) {
      return GridCell(backgroundColor: dayItem.backgroundColor, child: Center(child: Text(dayItem.date)));
    }

    T? value;

    if (fixColumnProfile == FixColumnProfile.columnProfileDateTimeValue) {
      Widget gridCellChild = Container();
      value = dayItem.all;
      if (xIndex == 1 && value != null) {
        gridCellChild = Center(child: Text(DateTimeUtils.formatTime(value.dateTime)));
      } else if (xIndex == 2 && value != null) {
        gridCellChild = gridCellChildBuilder(value, cellSize);
      }

      return GridCell(backgroundColor: dayItem.backgroundColor, child: gridCellChild);
    }

    if (fixColumnProfile == FixColumnProfile.columnProfileDateMorningMiddayEvening) {
      if (xIndex == 1) {
        value = dayItem.morning;
      } else if (xIndex == 2) {
        value = dayItem.midday;
      } else {
        value = dayItem.evening;
      }

      Widget gridCellChild = Container();
      if (value != null) {
        gridCellChild = gridCellChildBuilder(value, cellSize);
      }
      return GridCell(
        backgroundColor: dayItem.backgroundColor,
        child: gridCellChild,
      );
    }

    // Fallback
    SimpleLogging.w("Unsupported column profile '${fixColumnProfile.type}' in RowPerDayCellBuilder!");
    return GridCell(
      backgroundColor: dayItem.backgroundColor,
      child: Container(height: 2, width: 2, color: Colors.red),
    );
  }
}
