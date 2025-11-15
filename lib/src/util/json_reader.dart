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

  JsonReader at(String key) {
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

  JsonReader? atOrNull(String key) {
    if (_value is! Map) return null;
    if (!_value.containsKey(key)) return null;
    if (_value[key] == null) return null;
    return JsonReader(_value[key], [..._path, key]);
  }

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
    if (_value is! List) {
      throw JsonParseException('Expected List at $pathString but found ${_value.runtimeType}');
    }

    final list = _value;

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

  String atAsString(String key) => at(key).getString();

  int atAsInt(String key) => at(key).getInt();

  double atAsDouble(String key) => at(key).getDouble();

  bool atAsBool(String key) => at(key).getBool();

  Map<String, dynamic> atAsMap(String key) => at(key).getMap();

  List<dynamic> atAsList(String key) => at(key).getList();

  // ------------------------------------------------------------
  // SHORTCUTS: OPTIONAL LEAF ACCESS
  // ------------------------------------------------------------

  String? atAsStringOrNull(String key) => atOrNull(key)?.getString();

  int? atAsIntOrNull(String key) => atOrNull(key)?.getInt();

  double? atAsDoubleOrNull(String key) => atOrNull(key)?.getDouble();

  bool? atAsBoolOrNull(String key) => atOrNull(key)?.getBool();

  Map<String, dynamic>? atAsMapOrNull(String key) => atOrNull(key)?.getMap();

  List<dynamic>? atAsListOrNull(String key) => atOrNull(key)?.getList();

  // ------------------------------------------------------------
  // SHORTCUTS WITH DEFAULT VALUES
  // ------------------------------------------------------------

  String atAsStringOr(String key, String def) => atAsStringOrNull(key) ?? def;

  int atAsIntOr(String key, int def) => atAsIntOrNull(key) ?? def;

  double atAsDoubleOr(String key, double def) => atAsDoubleOrNull(key) ?? def;

  bool atAsBoolOr(String key, bool def) => atAsBoolOrNull(key) ?? def;

  Map<String, dynamic> atAsMapOr(String key, Map<String, dynamic> def) => atAsMapOrNull(key) ?? def;

  List<dynamic> atAsListOr(String key, List<dynamic> def) => atAsListOrNull(key) ?? def;
}
