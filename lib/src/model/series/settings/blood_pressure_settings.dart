import 'series_settings.dart';

class BloodPressureSettings extends SeriesSettings {
  static const String _prefix = 'bloodPressure';
  final String _hideMedicationInput = 'HideMedicationInput';

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  BloodPressureSettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  bool get hideMedicationInput {
    return getBool(_hideMedicationInput);
  }

  set hideMedicationInput(bool value) {
    set(_hideMedicationInput, value);
  }
}
