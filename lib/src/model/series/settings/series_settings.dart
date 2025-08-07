abstract class SeriesSettings {
  final String _prefix;

  /// call rebuild in the editor
  final Function()? _updateStateCB;

  /// settings map ref
  final Map<String, dynamic> _settings;

  SeriesSettings(this._prefix, this._settings, this._updateStateCB);

  String _key(String suffix) => "${_prefix}_$suffix";

  void set(String key, dynamic value) {
    // update callback available?
    if (_updateStateCB != null) {
      _settings[_key(key)] = value;
      _updateStateCB();
    }
  }

  bool getBool(String key) {
    return _settings[_key(key)] as bool? ?? false;
  }
}
