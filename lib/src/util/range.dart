class Range<K, V> {
  K from;
  V to;

  Range(this.from, this.to);

  @override
  String toString() {
    return 'Range{from: $from, to: $to}';
  }
}
