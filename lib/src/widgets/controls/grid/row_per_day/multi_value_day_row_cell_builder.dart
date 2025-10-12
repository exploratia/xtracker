import 'package:flutter/material.dart';

import '../../../../model/column_profile/fix_column_profile.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../util/logging/flutter_simple_logging.dart';
import '../two_dimensional_scrollable_table.dart';
import 'multi_value_day_row_item.dart';

class MultiValueDayRowCellBuilder<T extends SeriesDataValue> {
  final List<MultiValueDayRowItem<T>> data;
  final Widget Function(MultiValueDayRowItem<T> multiValueDayRowItem, Size cellSize) gridCellChildBuilder;
  final FixColumnProfile fixColumnProfile;

  MultiValueDayRowCellBuilder({required this.data, required this.gridCellChildBuilder, required this.fixColumnProfile});

  GridCell gridCellBuilder(BuildContext context, int yIndex, int xIndex, Size cellSize) {
    MultiValueDayRowItem<T> dayItem = data[yIndex];

    if (xIndex == 0) {
      return GridCell(backgroundColor: dayItem.backgroundColor, child: Center(child: Text(dayItem.date)));
    }

    if (FixColumnProfile.isMultiValueDayProfile(fixColumnProfile)) {
      Widget gridCellChild = Container();
      if (xIndex == 1) {
        gridCellChild = gridCellChildBuilder(dayItem, cellSize);
      }

      return GridCell(backgroundColor: dayItem.backgroundColor, child: gridCellChild);
    }

    // Fallback
    SimpleLogging.w("Unsupported column profile '${fixColumnProfile.type}' in MultiValueRowPerDayCellBuilder!");
    return GridCell(
      backgroundColor: dayItem.backgroundColor,
      child: Container(height: 2, width: 2, color: Colors.red),
    );
  }
}
