import '../series_settings.dart';
import 'daily_life_attribute.dart';

class DailyLifeAttributesSettings extends SeriesSettings {
  static const String _prefix = 'dailyLifeAttributes';
  final String _attributes = 'Attributes';

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  DailyLifeAttributesSettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  List<DailyLifeAttribute> get attributes {
    return DailyLifeAttribute.parseJsonList(getList(_attributes));
  }

  set attributes(List<DailyLifeAttribute> value) {
    set(_attributes, DailyLifeAttribute.toJsonList(value));
  }
}
