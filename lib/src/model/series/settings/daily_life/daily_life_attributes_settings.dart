import 'package:easy_localization/easy_localization.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../util/ex.dart';
import '../../series_def.dart';
import '../../series_type.dart';
import '../series_settings.dart';
import 'daily_life_attribute.dart';

class DailyLifeAttributesSettings extends SeriesSettings {
  static const String _prefix = 'dailyLifeAttributes';
  static const String _attributesKey = 'Attributes';
  List<DailyLifeAttribute>? _attributes;

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  DailyLifeAttributesSettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  List<DailyLifeAttribute> get attributes {
    _attributes ??= DailyLifeAttribute.parseJsonList(getList(_attributesKey));
    return [..._attributes!];
  }

  set attributes(List<DailyLifeAttribute> value) {
    set(_attributesKey, DailyLifeAttribute.toJsonList(value));
    _attributes = [...value];
  }

  bool isValid() {
    return attributes.isNotEmpty;
  }

  /// throws exception if not valid
  static void validate(SeriesDef seriesDef) {
    if (seriesDef.seriesType != SeriesType.dailyLife) return;
    var checkSettings = seriesDef.dailyLifeAttributesSettingsReadonly();
    if (checkSettings.attributes.isEmpty) throw Ex(LocaleKeys.seriesManagement_importExport_validation_dailyLife_emptyAttributes.tr());
  }
}
