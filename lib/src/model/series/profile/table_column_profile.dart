class TableColumnProfile {
  final List<TableColumn> columns;

  TableColumnProfile({required this.columns});

  int minWidth() {
    return columns.fold(0, (previousValue, element) => previousValue + element.minWidth);
  }

  TableColumn getColumnAt(int index) {
    if (index >= 0 && index < columns.length) {
      return columns[index];
    }

    // fallback - should never happen
    return TableColumn(minWidth: 200);
  }
}

class TableColumn {
  final int minWidth;

  TableColumn({required this.minWidth});
}
