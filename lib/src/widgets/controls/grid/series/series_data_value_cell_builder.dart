import 'package:flutter/material.dart';

import '../../../../model/column_profile/column_profile.dart';
import '../../../../model/column_profile/column_type.dart';
import '../../../../model/series/data/series_data.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../util/theme_utils.dart';
import '../two_dimensional_scrollable_table.dart';
import 'series_data_value_grid_item.dart';

class SeriesDataValueCellBuilder<T extends SeriesDataValue> {
  final List<SeriesDataValueGridItem<T>> data;
  final Widget Function(T value, Size cellSize, ColumnDef columnDef) gridCellChildBuilder;
  final ColumnProfile columnProfile;
  final bool editMode;

  SeriesDataValueCellBuilder({
    required this.data,
    required this.gridCellChildBuilder,
    required this.columnProfile,
    this.editMode = false,
  });

  GridCell gridCellBuilder(BuildContext context, int yIndex, int xIndex, Size cellSize) {
    SeriesDataValueGridItem<T> gridItem = data[yIndex];
    var columnDef = columnProfile.columns[xIndex];

    Widget? child;
    if (columnDef.columnType == ColumnType.date) {
      if (gridItem.date != null) {
        child = Center(child: Text(gridItem.date!));
      }
    } else if (columnDef.columnType == ColumnType.time) {
      if (gridItem.time != null) {
        child = Center(child: Text(gridItem.time!));
      }
    } else if (columnDef.columnType == ColumnType.dateTime) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: ThemeUtils.horizontalSpacingLarge,
        children: [
          if (gridItem.date != null) Text(gridItem.date!),
          if (gridItem.time != null) Text(gridItem.time!),
        ],
      );
    } else {
      child = gridCellChildBuilder(gridItem.value, cellSize, columnDef);

      if (editMode) {
        child = InkWell(
          borderRadius: ThemeUtils.borderRadiusCircularSmall,
          onTap: () => SeriesData.showSeriesDataInputDlg(context, gridItem.seriesDef, value: gridItem.value),
          child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(radius: 0.8, colors: [ThemeUtils.primaryColor.withAlpha(128), ThemeUtils.primaryColor.withAlpha(0)]),
              ),
              child: child),
        );
      }
    }
    child ??= Container();
    return GridCell(backgroundColor: gridItem.backgroundColor, child: child);
  }
}
