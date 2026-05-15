import 'package:easy_localization/easy_localization.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../util/ex.dart';
import '../../series_def.dart';
import '../../series_type.dart';
import '../../tags/tag.dart';
import '../series_settings.dart';

class DailyLifeTagsSettings extends SeriesSettings {
  static const String _prefix = 'tags';
  static const String _tagsKey = 'TagList';
  List<Tag>? _tags;

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  DailyLifeTagsSettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  List<Tag> get tags {
    _tags ??= Tag.parseJsonList(getList(_tagsKey));
    return [..._tags!];
  }

  set tags(List<Tag> value) {
    set(_tagsKey, Tag.toJsonList(value));
    _tags = [...value];
  }

  bool isValid() {
    return tags.isNotEmpty;
  }

  /// throws exception if not valid
  static void validate(SeriesDef seriesDef) {
    if (seriesDef.seriesType != SeriesType.dailyLife) return;
    var checkSettings = seriesDef.dailyLifeTagsSettingsReadonly();
    if (checkSettings.tags.isEmpty) {
      throw Ex(
        "${seriesDef.seriesType} has empty tags.",
        localizedMessage: LocaleKeys.seriesManagement_importExport_validation_dailyLife_emptyTags.tr(),
      );
    }
  }
}
