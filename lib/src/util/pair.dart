class Pair<K, V> {
  K k;
  V v;

  Pair(this.k, this.v);

  @override
  String toString() {
    return 'Pair{k: $k, v: $v}';
  }
}
