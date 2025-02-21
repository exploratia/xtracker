class TableColumnProfile {
  final List<TableColumn> columns;

  TableColumnProfile({required this.columns});

  int minWidth() {
    return columns.fold(0, (previousValue, element) => previousValue + element.minWidth);
  }
}

class TableColumn {
  final int minWidth;

  TableColumn({required this.minWidth});
}
