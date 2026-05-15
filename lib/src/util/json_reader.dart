class JsonParseException implements Exception {
  final String message;

  JsonParseException(this.message);

  @override
  String toString() => 'JsonParseException: $message';
}

class JsonReader {
  final dynamic _value;
  final List<String> _path;

  JsonReader(this._value, [List<String>? path]) : _path = path ?? [];

  // ------------------------------------------------------------
  // PATH HANDLING
  // ------------------------------------------------------------

  String get pathString {
    if (_path.isEmpty) return 'root';
    return 'root.${_path.map((p) => p.startsWith('[') ? p : '.$p').join().substring(1)}';
  }

  // ------------------------------------------------------------
  // ACCESSORS
  // ------------------------------------------------------------

  JsonReader asReader(String key) {
    if (_value is! Map) {
      throw JsonParseException('Expected Map at $pathString but found ${_value.runtimeType}');
    }

    if (!_value.containsKey(key)) {
      throw JsonParseException('Missing property "$key" at $pathString');
    }

    if (_value[key] == null) {
      throw JsonParseException('Found null Property "$key" at $pathString');
    }

    return JsonReader(_value[key], [..._path, key]);
  }

  JsonReader? asReaderOrNull(String key) {
    if (_value is! Map) return null;
    if (!_value.containsKey(key)) return null;
    if (_value[key] == null) return null;
    return JsonReader(_value[key], [..._path, key]);
  }

  /// index access (expects value to be a list)
  JsonReader index(int i) {
    if (_value is! List) {
      throw JsonParseException('Expected List at $pathString but found ${_value.runtimeType}');
    }
    if (i < 0 || i >= _value.length) {
      throw JsonParseException('Index $i out of range at $pathString');
    }

    return JsonReader(_value[i], [..._path, '[$i]']);
  }

  // ------------------------------------------------------------
  // TYPED GETTERS — STRICT
  // ------------------------------------------------------------

  String getString() {
    if (_value is String) return _value;
    throw JsonParseException('Expected String at $pathString but found ${_value.runtimeType}');
  }

  int getInt() {
    if (_value is int) return _value;
    throw JsonParseException('Expected int at $pathString but found ${_value.runtimeType}');
  }

  double getDouble() {
    if (_value is num) return _value.toDouble();
    throw JsonParseException('Expected num at $pathString but found ${_value.runtimeType}');
  }

  bool getBool() {
    if (_value is bool) return _value;
    throw JsonParseException('Expected bool at $pathString but found ${_value.runtimeType}');
  }

  Map<String, dynamic> getMap() {
    if (_value is Map<String, dynamic>) return _value;
    throw JsonParseException('Expected Map<String,dynamic> at $pathString but found ${_value.runtimeType}');
  }

  List<dynamic> getList() {
    if (_value is List) return _value;
    throw JsonParseException('Expected List at $pathString but found ${_value.runtimeType}');
  }

  //
  // // ------------------------------------------------------------
  // // OPTIONAL GETTERS
  // // ------------------------------------------------------------
  //
  // String? getStringOrNull() => _value is String ? _value : null;
  //
  // int? getIntOrNull() => _value is int ? _value : null;
  //
  // double? getDoubleOrNull() => _value is num ? (_value).toDouble() : null;
  //
  // bool? getBoolOrNull() => _value is bool ? _value : null;
  //
  // Map<String, dynamic>? getMapOrNull() => _value is Map<String, dynamic> ? _value : null;
  //
  // List<dynamic>? getListOrNull() => _value is List ? _value : null;
  //
  // // ------------------------------------------------------------
  // // DEFAULT GETTERS
  // // ------------------------------------------------------------
  //
  // String getStringOr(String def) => _value is String ? _value : def;
  //
  // int getIntOr(int def) => _value is int ? _value : def;
  //
  // double getDoubleOr(double def) => _value is num ? (_value).toDouble() : def;
  //
  // bool getBoolOr(bool def) => _value is bool ? _value : def;
  //
  // Map<String, dynamic> getMapOr(Map<String, dynamic> def) => _value is Map<String, dynamic> ? _value : def;
  //
  // List<dynamic> getListOr(List<dynamic> def) => _value is List ? _value : def;

  // ------------------------------------------------------------
  // ITERABLE OF JsonReaders
  // ------------------------------------------------------------

  /// Strict: throws if no List
  Iterable<JsonReader> asReaders() {
    final list = getList();

    // Lazy generator
    return Iterable.generate(
      list.length,
      (i) => JsonReader(list[i], [..._path, '[$i]']),
    );
  }

  /// Optional: returns empty iterable if current value is not a list
  Iterable<JsonReader> asReadersOrEmpty() {
    if (_value is! List) return const [];
    final list = _value;
    return Iterable.generate(
      list.length,
      (i) => JsonReader(list[i], [..._path, '[$i]']),
    );
  }

  // ------------------------------------------------------------
  // ITERABLES FOR MAPS (unknown keys)
  // ------------------------------------------------------------

  /// Strict: iterable over key → JsonReader
  Iterable<MapEntry<String, JsonReader>> asMapReaders() {
    if (_value is! Map) {
      throw JsonParseException('Expected Map at $pathString but found ${_value.runtimeType}');
    }

    final map = _value as Map<String, dynamic>;

    return map.entries.map(
      (e) => MapEntry(
        e.key,
        JsonReader(e.value, [..._path, e.key]),
      ),
    );
  }

  /// Optional: returns empty iterable if not a map
  Iterable<MapEntry<String, JsonReader>> asMapReadersOrEmpty() {
    if (_value is! Map) return const [];
    final map = _value as Map<String, dynamic>;

    return map.entries.map(
      (e) => MapEntry(
        e.key,
        JsonReader(e.value, [..._path, e.key]),
      ),
    );
  }

  /// Convenience: list of keys (strict)
  Iterable<String> keys() {
    if (_value is! Map) {
      throw JsonParseException('Expected Map at $pathString but found ${_value.runtimeType}');
    }
    return _value.keys.cast<String>();
  }

  /// Convenience: iterable of JsonReader values (strict)
  Iterable<JsonReader> valuesAsReaders() {
    if (_value is! Map) {
      throw JsonParseException('Expected Map at $pathString but found ${_value.runtimeType}');
    }

    final map = _value as Map<String, dynamic>;

    return map.entries.map(
      (e) => JsonReader(e.value, [..._path, e.key]),
    );
  }

  // ------------------------------------------------------------
  // SHORTCUTS: STRICT LEAF ACCESS
  // ------------------------------------------------------------

  String asString(String key) => asReader(key).getString();

  int asInt(String key) => asReader(key).getInt();

  double asDouble(String key) => asReader(key).getDouble();

  bool asBool(String key) => asReader(key).getBool();

  Map<String, dynamic> asMap(String key) => asReader(key).getMap();

  List<dynamic> asList(String key) => asReader(key).getList();

  // ------------------------------------------------------------
  // SHORTCUTS: OPTIONAL LEAF ACCESS
  // ------------------------------------------------------------

  String? asStringOrNull(String key) => asReaderOrNull(key)?.getString();

  int? asIntOrNull(String key) => asReaderOrNull(key)?.getInt();

  double? asDoubleOrNull(String key) => asReaderOrNull(key)?.getDouble();

  bool? asBoolOrNull(String key) => asReaderOrNull(key)?.getBool();

  Map<String, dynamic>? asMapOrNull(String key) => asReaderOrNull(key)?.getMap();

  List<dynamic>? asListOrNull(String key) => asReaderOrNull(key)?.getList();

  // ------------------------------------------------------------
  // SHORTCUTS WITH DEFAULT VALUES
  // ------------------------------------------------------------

  String asStringOr(String key, String def) => asStringOrNull(key) ?? def;

  int asIntOr(String key, int def) => asIntOrNull(key) ?? def;

  double asDoubleOr(String key, double def) => asDoubleOrNull(key) ?? def;

  bool asBoolOr(String key, bool def) => asBoolOrNull(key) ?? def;

  Map<String, dynamic> asMapOr(String key, Map<String, dynamic> def) => asMapOrNull(key) ?? def;

  List<dynamic> asListOr(String key, List<dynamic> def) => asListOrNull(key) ?? def;
}
