import 'series_settings.dart';

class BloodPressureSettings extends SeriesSettings {
  static const String _prefix = 'bloodPressure';
  final String _hideMedicationInput = 'HideMedicationInput';

  /// [updateState] optional callback which is called when the settings map is changed. If not set readonly.
  BloodPressureSettings(Map<String, dynamic> settings, Function()? updateState) : super(_prefix, settings, updateState);

  bool get hideMedicationInput {
    return getBool(_hideMedicationInput);
  }

  set hideMedicationInput(bool value) {
    set(_hideMedicationInput, value);
  }
}
