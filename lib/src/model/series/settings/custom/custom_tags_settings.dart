import '../../series_def.dart';
import '../../tags/tag.dart';
import '../series_settings.dart';

class CustomTagsSettings extends SeriesSettings {
  static const String _prefix = 'tags';
  static const String _tagsKey = 'TagList';
  List<Tag>? _tags;

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  CustomTagsSettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  List<Tag> get tags {
    _tags ??= Tag.parseJsonList(getList(_tagsKey));
    return [..._tags!];
  }

  set tags(List<Tag> value) {
    set(_tagsKey, Tag.toJsonList(value));
    _tags = [...value];
  }

  bool isValid() {
    return true; // tags.isNotEmpty;
  }

  bool isNotEmpty() {
    return tags.isNotEmpty;
  }

  /// throws exception if not valid
  static void validate(SeriesDef seriesDef) {
    // nothing to validate... empty tags list is allowed for custom/monthly
  }
}
