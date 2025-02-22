class TableColumnProfile {
  final List<TableColumn> columns;
  final bool hasHorizontalMarginColumns;

  TableColumnProfile({
    required this.columns,
    this.hasHorizontalMarginColumns = false,
  });

  double minWidth() {
    return columns.fold(0, (previousValue, element) => previousValue + element.minWidth);
  }

  int length() {
    return columns.length;
  }

  TableColumn getColumnAt(int index) {
    if (index >= 0 && index < columns.length) {
      return columns[index];
    }

    // fallback - should never happen
    return TableColumn(minWidth: 200);
  }

  /// stretch to given width
  TableColumnProfile adjustToWidth(double width) {
    double minW = minWidth().toDouble();
    // is column profile wider then available width - return
    if (minW >= width) return this;

    // otherwise adjust
    bool addMargin = false;
    double horizontalMargin = -1000;

    double widthFactor = width / minW;
    // if too wide limit and add margin to first (=date) column
    if (widthFactor > 2) {
      widthFactor = 2;
      addMargin = true;
    }
    List<TableColumn> adjustedColumns = columns.map((e) => TableColumn(minWidth: (e.minWidth * widthFactor))).toList();

    if (addMargin) {
      var adjustedWidth = adjustedColumns.fold(0.toDouble(), (previousValue, element) => previousValue + element.minWidth);
      horizontalMargin = (width - adjustedWidth) / 2;
      adjustedColumns = [
        TableColumn(minWidth: horizontalMargin, isMarginColumn: true),
        ...adjustedColumns,
        TableColumn(minWidth: horizontalMargin, isMarginColumn: true),
      ];
    }

    return TableColumnProfile(columns: adjustedColumns, hasHorizontalMarginColumns: horizontalMargin >= 0);
  }

  @override
  String toString() {
    return 'TableColumnProfile{columns: $columns}';
  }
}

class TableColumn {
  final double minWidth;
  final bool isMarginColumn;

  TableColumn({required this.minWidth, this.isMarginColumn = false});

  @override
  String toString() {
    return 'TableColumn{minWidth: $minWidth}';
  }
}
