enum ColumnType {
  /// left/right margin column to center table
  margin,
  date,
  time,
  dateTime,
  number,
  text,
  tag,

  /// unspecified value - could be text, number (as text) or own widget
  value,
}
