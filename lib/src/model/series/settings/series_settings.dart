abstract class SeriesSettings {
  final String _prefix;

  /// call rebuild in the editor
  final Function()? _updateStateCB;

  /// settings map ref
  final Map<String, dynamic> _settings;

  SeriesSettings(this._prefix, this._settings, this._updateStateCB);

  String _key(String suffix) => "$_prefix$suffix";

  void set(String key, dynamic value) {
    // update callback available?
    if (_updateStateCB != null) {
      if (value == null) {
        _settings.remove(_key(key));
      } else {
        _settings[_key(key)] = value;
      }
      _updateStateCB();
    }
  }

  dynamic get(String key) {
    return _settings[_key(key)];
  }

  String getString(String key, {String defaultValue = ""}) {
    return _settings[_key(key)] as String? ?? defaultValue;
  }

  String? optString(String key, {String? defaultValue}) {
    return _settings[_key(key)] as String? ?? defaultValue;
  }

  List<dynamic> getList(String key) {
    return _settings[_key(key)] as List<dynamic>? ?? [];
  }

  bool getBool(String key) {
    return _settings[_key(key)] as bool? ?? false;
  }

  double getDouble(String key, {double defaultValue = 0}) {
    return _settings[_key(key)] as double? ?? defaultValue;
  }
}
