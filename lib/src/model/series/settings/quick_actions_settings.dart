import 'series_settings.dart';

class QuickActionsSettings extends SeriesSettings {
  static const String _prefix = 'quickActions';
  final String _showAddValueInAppContextMenu = 'ShowAddValueInAppContextMenu';

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  QuickActionsSettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  bool get showAddValueInAppContextMenu {
    return getBool(_showAddValueInAppContextMenu);
  }

  set showAddValueInAppContextMenu(bool value) {
    set(_showAddValueInAppContextMenu, value == true ? true : null);
  }
}
