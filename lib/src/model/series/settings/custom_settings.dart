import 'series_settings.dart';

class CustomSettings extends SeriesSettings {
  static const String _prefix = 'custom';

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  CustomSettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);
}
