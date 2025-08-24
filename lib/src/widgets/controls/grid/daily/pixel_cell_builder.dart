import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data_value.dart';
import '../two_dimensional_scrollable_table.dart';
import 'day/day_item.dart';
import 'pixel.dart';
import 'row/row_item.dart';

class PixelCellBuilder<T extends DayItem> {
  final List<RowItem<T>> data;
  final Pixel Function(T dayItem) gridCellChildBuilder;
  final bool monthly;

  /// [gridCellChildBuilder] will be called for dayItems with count > 0
  PixelCellBuilder({
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

    // empty pixel?
    if (dayItem.count <= 0) {
      return GridCell(
        child: Pixel<SeriesDataValue>(
          colors: [],
          backgroundColor: dayItem.backgroundColor,
          pixelText: null,
          isStartMarker: monthly ? false : dayItem.dateTimeDayStart.day == 1,
          seriesValues: [],
        ),
      );
    }

    return GridCell(child: gridCellChildBuilder(dayItem));
  }
}
