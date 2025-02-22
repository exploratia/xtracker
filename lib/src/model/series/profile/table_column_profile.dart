class TableColumnProfile {
  final List<TableColumn> columns;
  final double marginLeft;

  TableColumnProfile({
    required this.columns,
    this.marginLeft = 0,
  });

  int minWidth() {
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
    double marginLeft = 0;

    double widthFactor = width / minW;
    // if too wide limit and add margin to first (=date) column
    if (widthFactor > 2) {
      widthFactor = 2;
      addMargin = true;
    }
    List<TableColumn> adjustedColumns = columns.map((e) => TableColumn(minWidth: (e.minWidth * widthFactor).truncate())).toList();

    if (addMargin) {
      var adjustedWidth = adjustedColumns.fold(0, (previousValue, element) => previousValue + element.minWidth);
      marginLeft = (width - adjustedWidth) / 2;
      TableColumn firstColumn = adjustedColumns[0];
      firstColumn = TableColumn(minWidth: (firstColumn.minWidth + marginLeft).truncate());
      adjustedColumns = [firstColumn, ...adjustedColumns.sublist(1)];
    }

    return TableColumnProfile(columns: adjustedColumns, marginLeft: marginLeft);
  }

  @override
  String toString() {
    return 'TableColumnProfile{columns: $columns}';
  }
}

class TableColumn {
  final int minWidth;

  TableColumn({required this.minWidth});

  @override
  String toString() {
    return 'TableColumn{minWidth: $minWidth}';
  }
}
