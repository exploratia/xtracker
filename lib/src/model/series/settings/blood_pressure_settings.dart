class BloodPressureSettings {
  final String _prefix = 'bloodPressure';
  final String _hideMedicationInput = 'HideMedicationInput';

  /// call rebuild in the editor
  final Function() updateState;
  final Map<String, dynamic> settings;

  BloodPressureSettings(this.settings, this.updateState);

  String _key(String suffix) => _prefix + suffix;

  void _set(String key, dynamic value) {
    settings[_key(key)] = value;
    updateState();
  }

  bool get hideMedicationInput {
    return settings[_key(_hideMedicationInput)] as bool? ?? false;
  }

  set hideMedicationInput(bool value) {
    _set(_hideMedicationInput, value);
  }
}
