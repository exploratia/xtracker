class BloodPressureSettings {
  final String _prefix = 'bloodPressure';
  final String _hideTabletInput = 'HideTabletInput';

  /// call rebuild in the editor
  final Function() updateState;
  final Map<String, dynamic> settings;

  BloodPressureSettings(this.settings, this.updateState);

  String _key(String suffix) => _prefix + suffix;

  void _set(String key, dynamic value) {
    settings[_key(key)] = value;
    updateState();
  }

  bool get hideTabletInput {
    return settings[_key(_hideTabletInput)] as bool? ?? false;
  }

  set hideTabletInput(bool value) {
    _set(_hideTabletInput, value);
  }
}
