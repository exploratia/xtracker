import '../../../../util/ex.dart';
import '../../../../util/globals.dart';
import '../../data/daily_life/daily_life_value.dart';
import '../../series_def.dart';
import '../../series_type.dart';
import 'daily_life_attribute.dart';

class DailyLifeAttributeResolver {
  late final DailyLifeAttribute _fallbackAttribute;
  final Map<String, DailyLifeAttribute> _attributeUuid2Color = {};

  DailyLifeAttributeResolver(SeriesDef seriesDef) {
    if (seriesDef.seriesType != SeriesType.dailyLife) throw Ex("Unexpected series with not allowed series type!");
    var attributes = seriesDef.dailyLifeAttributesSettingsReadonly().attributes;
    for (var attribute in attributes) {
      _attributeUuid2Color[attribute.aid] = attribute;
    }
    _fallbackAttribute = DailyLifeAttribute(aid: Globals.invalid, color: seriesDef.color, name: seriesDef.name);
  }

  DailyLifeAttribute resolve(dynamic attributeOrUuid) {
    String uuid = Globals.invalid;
    if (attributeOrUuid is String) {
      uuid = attributeOrUuid;
    } else if (attributeOrUuid is DailyLifeValue) {
      uuid = attributeOrUuid.attributeUuid;
    }
    return _attributeUuid2Color[uuid] ?? _fallbackAttribute;
  }
}
