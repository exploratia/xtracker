import '../../../util/contrast_color.dart';
import '../../../util/ex.dart';
import '../../../util/globals.dart';
import '../data/custom/custom_value.dart';
import '../data/daily_life/daily_life_value.dart';
import '../series_def.dart';
import '../series_type.dart';
import 'tag.dart';

class TagResolver {
  static final List<SeriesType> _allowedSeriesTypes = [SeriesType.dailyLife, SeriesType.custom, SeriesType.monthly];

  late final Tag _fallbackTag;
  final Map<String, Tag> _tagUuid2Color = {};
  final List<String> tagIds = [];

  TagResolver(SeriesDef seriesDef) {
    if (!_allowedSeriesTypes.contains(seriesDef.seriesType)) throw Ex("Unexpected series with not allowed series type!");
    var tags = (seriesDef.seriesType == SeriesType.dailyLife) ? seriesDef.dailyLifeTagsSettingsReadonly().tags : seriesDef.customTagsSettingsReadonly().tags;
    for (var tag in tags) {
      _tagUuid2Color[tag.tagId] = tag;
      tagIds.add(tag.tagId);
    }
    _fallbackTag = Tag(
      tagId: Globals.invalid,
      color: ContrastColor.findMaxContrastColor(
        tags.map(
          (a) => a.color,
        ),
      ),
      name: seriesDef.name,
    );
  }

  Tag resolve(dynamic tagOrTagId) {
    String uuid = Globals.invalid;
    if (tagOrTagId is String) {
      uuid = tagOrTagId;
    } else if (tagOrTagId is DailyLifeValue) {
      uuid = tagOrTagId.tagId;
    } else if (tagOrTagId is CustomValue && tagOrTagId.tagId != null) {
      uuid = tagOrTagId.tagId ?? Globals.invalid;
    } else if (tagOrTagId is Tag) {
      uuid = tagOrTagId.tagId;
    }
    return _tagUuid2Color[uuid] ?? _fallbackTag;
  }

  /// compare two tags by order in series def
  int compare(dynamic tagOrTagId1, dynamic tagOrTagId2) {
    String tagId1 = resolve(tagOrTagId1).tagId;
    String tagId2 = resolve(tagOrTagId2).tagId;
    return tagIds.indexOf(tagId1).compareTo(tagIds.indexOf(tagId2));
  }

  bool isNotEmpty() {
    return tagIds.isNotEmpty;
  }
}
