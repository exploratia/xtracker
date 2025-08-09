import 'series_settings.dart';

class DisplaySettings extends SeriesSettings {
  static const String _prefix = 'display';
  final String _dotViewHideCount = 'DotsViewHideCount';

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  DisplaySettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  bool get dotsViewShowCount {
    return !getBool(_dotViewHideCount); // invert
  }

  set dotsViewShowCount(bool value) {
    set(_dotViewHideCount, !value); // invert
  }
}
