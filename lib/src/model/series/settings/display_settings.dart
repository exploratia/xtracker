import 'series_settings.dart';

class DisplaySettings extends SeriesSettings {
  static const String _prefix = 'display';
  final String _dotViewShowCount = 'dotsView_showCount';

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  DisplaySettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  bool get dotsViewShowCount {
    return getBool(_dotViewShowCount);
  }

  set dotsViewShowCount(bool value) {
    set(_dotViewShowCount, value);
  }
}
