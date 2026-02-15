import '../../../util/contrast_color.dart';
import '../../../util/ex.dart';
import '../../../util/globals.dart';
import '../data/custom/custom_value.dart';
import '../data/daily_life/daily_life_value.dart';
import '../series_def.dart';
import '../series_type.dart';
import 'attribute.dart';

class AttributeResolver {
  static final List<SeriesType> _allowedSeriesTypes = [SeriesType.dailyLife, SeriesType.custom, SeriesType.monthly];

  late final Attribute _fallbackAttribute;
  final Map<String, Attribute> _attributeUuid2Color = {};
  final List<String> attributeIds = [];

  AttributeResolver(SeriesDef seriesDef) {
    if (!_allowedSeriesTypes.contains(seriesDef.seriesType)) throw Ex("Unexpected series with not allowed series type!");
    var attributes = (seriesDef.seriesType == SeriesType.dailyLife)
        ? seriesDef.dailyLifeAttributesSettingsReadonly().attributes
        : seriesDef.customAttributesSettingsReadonly().attributes;
    for (var attribute in attributes) {
      _attributeUuid2Color[attribute.aid] = attribute;
      attributeIds.add(attribute.aid);
    }
    _fallbackAttribute = Attribute(
      aid: Globals.invalid,
      color: ContrastColor.findMaxContrastColor(
        attributes.map(
          (a) => a.color,
        ),
      ),
      name: seriesDef.name,
    );
  }

  Attribute resolve(dynamic attributeOrAid) {
    String uuid = Globals.invalid;
    if (attributeOrAid is String) {
      uuid = attributeOrAid;
    } else if (attributeOrAid is DailyLifeValue) {
      uuid = attributeOrAid.aid;
    } else if (attributeOrAid is CustomValue && attributeOrAid.aid != null) {
      uuid = attributeOrAid.aid ?? Globals.invalid;
    } else if (attributeOrAid is Attribute) {
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

  bool isNotEmpty() {
    return attributeIds.isNotEmpty;
  }
}
