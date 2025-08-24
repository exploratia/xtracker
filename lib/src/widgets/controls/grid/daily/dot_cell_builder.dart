import 'package:flutter/material.dart';

import '../two_dimensional_scrollable_table.dart';
import 'day/day_item.dart';
import 'dot.dart';
import 'row/row_item.dart';

class DotCellBuilder<T extends DayItem> {
  final List<RowItem<T>> data;
  final Dot Function(T dayItem) gridCellChildBuilder;
  final bool monthly;

  /// [gridCellChildBuilder] will be called for dayItems with count > 0
  DotCellBuilder({
    required this.data,
    required this.gridCellChildBuilder,
    required this.monthly,
  });

  GridCell gridCellBuilder(BuildContext context, int yIndex, int xIndex) {
    var rowItem = data[yIndex];

    if (xIndex == 0) {
      if (rowItem.displayDate != null) {
        return GridCell(child: Center(child: Text(rowItem.displayDate!)));
      }
      return GridCell(child: Container());
    }

    var dayItem = rowItem.getDayItem(xIndex - 1);
    if (dayItem == null) {
      return GridCell(child: Container());
    }

    // empty?
    if (dayItem.count <= 0) {
      return GridCell(
        backgroundColor: dayItem.backgroundColor,
        child: Dot.noValueDot(dayItem, monthly),
      );
    }

    return GridCell(backgroundColor: dayItem.backgroundColor, child: gridCellChildBuilder(dayItem));
  }
}
