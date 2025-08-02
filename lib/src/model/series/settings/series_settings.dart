class SeriesSettings {
  final String _prefix;

  /// call rebuild in the editor
  final Function()? _updateState;

  /// settings map ref
  final Map<String, dynamic> _settings;

  SeriesSettings(this._prefix, this._settings, this._updateState);

  String _key(String suffix) => _prefix + suffix;

  void set(String key, dynamic value) {
    // update callback available?
    if (_updateState != null) {
      _settings[_key(key)] = value;
      _updateState();
    }
  }

  bool getBool(String key) {
    return _settings[_key(key)] as bool? ?? false;
  }
}
