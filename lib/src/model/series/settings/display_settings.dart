import '../../column_profile/fix_column_profile.dart';
import '../../column_profile/fix_column_profile_type.dart';
import 'series_settings.dart';

class DisplaySettings extends SeriesSettings {
  static const String _prefix = 'display';
  final String _dotsViewHideCount = 'DotsViewHideCount';
  final String _pixelsViewInvertHueDirection = 'PixelsViewInvertHueDirection';
  final String _pixelsViewHueFactor = 'PixelsViewHueFactor';
  final String _tableViewColumnProfile = 'TableViewColumnProfile';

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  DisplaySettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  bool get dotsViewShowCount {
    return !getBool(_dotsViewHideCount); // invert
  }

  set dotsViewShowCount(bool value) {
    set(_dotsViewHideCount, !value); // invert
  }

  bool get pixelsViewInvertHueDirection {
    return getBool(_pixelsViewInvertHueDirection);
  }

  set pixelsViewInvertHueDirection(bool value) {
    set(_pixelsViewInvertHueDirection, value);
  }

  double get pixelsViewHueFactor {
    return getDouble(_pixelsViewHueFactor, defaultValue: 140);
  }

  set pixelsViewHueFactor(double value) {
    set(_pixelsViewHueFactor, value);
  }

  FixColumnProfile? getTableViewColumnProfile(FixColumnProfileType? defaultValue) {
    return FixColumnProfile.resolveByType(FixColumnProfileType.resolveByTypeName(optString(_tableViewColumnProfile, defaultValue: defaultValue?.typeName)));
  }

  set tableViewColumnProfile(FixColumnProfileType? value) {
    set(_tableViewColumnProfile, value?.typeName);
  }
}
