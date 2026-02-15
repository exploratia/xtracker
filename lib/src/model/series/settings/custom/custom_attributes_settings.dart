import '../../attributes/attribute.dart';
import '../../series_def.dart';
import '../series_settings.dart';

class CustomAttributesSettings extends SeriesSettings {
  static const String _prefix = 'attributes';
  static const String _attributesKey = 'Attributes';
  List<Attribute>? _attributes;

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  CustomAttributesSettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  List<Attribute> get attributes {
    _attributes ??= Attribute.parseJsonList(getList(_attributesKey));
    return [..._attributes!];
  }

  set attributes(List<Attribute> value) {
    set(_attributesKey, Attribute.toJsonList(value));
    _attributes = [...value];
  }

  bool isValid() {
    return true; // attributes.isNotEmpty;
  }

  /// throws exception if not valid
  static void validate(SeriesDef seriesDef) {
    // nothing to validate... empty attributes list is allowed for custom/monthly
  }
}
