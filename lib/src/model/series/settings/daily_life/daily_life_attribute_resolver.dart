import '../../../../util/contrast_color.dart';
import '../../../../util/ex.dart';
import '../../../../util/globals.dart';
import '../../data/daily_life/daily_life_value.dart';
import '../../series_def.dart';
import '../../series_type.dart';
import 'daily_life_attribute.dart';

class DailyLifeAttributeResolver {
  late final DailyLifeAttribute _fallbackAttribute;
  final Map<String, DailyLifeAttribute> _attributeUuid2Color = {};
  final List<String> attributeIds = [];

  DailyLifeAttributeResolver(SeriesDef seriesDef) {
    if (seriesDef.seriesType != SeriesType.dailyLife) throw Ex("Unexpected series with not allowed series type!");
    var attributes = seriesDef.dailyLifeAttributesSettingsReadonly().attributes;
    for (var attribute in attributes) {
      _attributeUuid2Color[attribute.aid] = attribute;
      attributeIds.add(attribute.aid);
    }
    _fallbackAttribute = DailyLifeAttribute(
        aid: Globals.invalid,
        color: ContrastColor.findMaxContrastColor(attributes.map(
          (a) => a.color,
        )),
        name: seriesDef.name);
  }

  DailyLifeAttribute resolve(dynamic attributeOrAid) {
    String uuid = Globals.invalid;
    if (attributeOrAid is String) {
      uuid = attributeOrAid;
    } else if (attributeOrAid is DailyLifeValue) {
      uuid = attributeOrAid.aid;
    } else if (attributeOrAid is DailyLifeAttribute) {
      uuid = attributeOrAid.aid;
    }
    return _attributeUuid2Color[uuid] ?? _fallbackAttribute;
  }

  /// compare two attributes by order in series def
  int compare(dynamic attributeOrAid1, dynamic attributeOrAid2) {
    String aid1 = resolve(attributeOrAid1).aid;
    String aid2 = resolve(attributeOrAid2).aid;
    return attributeIds.indexOf(aid1).compareTo(attributeIds.indexOf(aid2));
  }
}
