import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/settings/daily_life/daily_life_tags_settings.dart';
import '../../../../model/series/tags/tag.dart';
import '../../../../util/color_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/btn/info_btn.dart';
import '../../../controls/tag/tag_edit_renderer.dart';
import '../../../controls/tag/tag_input.dart';

class DailyLifeSeriesEditTags extends StatelessWidget {
  final SeriesDef seriesDef;
  final DailyLifeTagsSettings dailyLifeTagsSettings;

  const DailyLifeSeriesEditTags(this.seriesDef, this.dailyLifeTagsSettings, {super.key});

  @override
  Widget build(BuildContext context) {
    var tags = dailyLifeTagsSettings.tags;
    List<Widget> listItems = [];

    updateSettings() => dailyLifeTagsSettings.tags = tags;

    for (var i = 0; i < tags.length; ++i) {
      var tag = tags[i];
      var renderer = TagEditRenderer(
        key: Key("tag_list_item_${tag.tagId}"),
        tag: Tag(tagId: tag.tagId, color: tag.color, name: tag.name),
        index: i,
        updateTagCB: (Tag updatedDailyLifeTag) {
          var idx = tags.indexWhere((a) => a.tagId == updatedDailyLifeTag.tagId);
          if (idx >= 0) {
            tags.replaceRange(idx, idx + 1, [updatedDailyLifeTag]);
            updateSettings();
          }
        },
        deleteTagCB: (Tag deletedDailyLifeTag) {
          tags.removeWhere((a) => a.tagId == deletedDailyLifeTag.tagId);
          updateSettings();
        },
      );
      listItems.add(renderer);
    }

    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InfoBtn(
            title: LocaleKeys.seriesEdit_seriesSettings_tags_title.tr(),
            content: LocaleKeys.seriesEdit_seriesSettings_tags_info.tr(),
          ),
          Expanded(child: Container()),
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.seriesEdit_seriesSettings_tags_actions_add_tooltip.tr(),
            onPressed: () async {
              Tag? dailyLifeTag = await TagInput.showInputDlg(context, newTagColor: seriesDef.color);
              if (dailyLifeTag != null) {
                tags.insert(0, dailyLifeTag);
                updateSettings();
              }
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton(
            iconSize: ThemeUtils.iconSizeScaled,
            borderRadius: ThemeUtils.borderRadiusCircular,
            icon: const Icon(Icons.playlist_add_outlined),
            tooltip: LocaleKeys.seriesEdit_seriesSettings_tags_actions_addPreset_tooltip.tr(),
            itemBuilder: (context) => _buildPresets(tags, updateSettings),
          ),
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.seriesEdit_seriesSettings_tags_actions_deleteAll_tooltip.tr(),
            onPressed: () async {
              tags.clear();
              updateSettings();
            },
            icon: const Icon(Icons.playlist_remove_outlined),
          ),
        ],
      ),
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return Opacity(
          opacity: 0.6,
          child: Material(
            // elevation: ThemeUtils.elevation, // Shadow effect while dragging
            borderRadius: BorderRadius.circular(ThemeUtils.borderRadiusLarge), // Rounded corners
            color: Colors.transparent,
            child: child,
          ),
        );
      },
      padding: const EdgeInsets.all(ThemeUtils.cardPadding),
      children: listItems,
      onReorderItem: (int oldIndex, int newIndex) {
        if (tags.length <= oldIndex || tags.length <= newIndex) return;

        final item = tags.removeAt(oldIndex);
        tags.insert(newIndex, item);
        updateSettings();
      },
    );
  }

  List<PopupMenuItem<dynamic>> _buildPresets(List<Tag> tags, List<Tag> Function() updateSettings) {
    int now = DateTime.now().millisecondsSinceEpoch;
    return [
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_feelings_title.tr()),
        onTap: () {
          tags.addAll(
            _buildFrom(LocaleKeys.seriesEdit_seriesSettings_tags_preset_feelings_tagNames.tr(), [
              ColorUtils.fromHex("#cb2526"),
              ColorUtils.fromHex("#ef8110"),
              ColorUtils.fromHex("#e6ca4a"),
              ColorUtils.fromHex("#5bab4a"),
              ColorUtils.fromHex("#557d75"),
              ColorUtils.fromHex("#649bd8"),
              ColorUtils.fromHex("#0c155a"),
              ColorUtils.fromHex("#9a457e"),
              ColorUtils.fromHex("#303030"),
            ]),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_sports_title.tr()),
        onTap: () {
          tags.addAll(
            _buildFrom(LocaleKeys.seriesEdit_seriesSettings_tags_preset_sports_tagNames.tr(), [
              Colors.orangeAccent,
              Colors.deepOrange,
              Colors.lightGreenAccent,
              Colors.blueGrey,
              Colors.green,
              Colors.blueAccent,
              Colors.purple,
            ]),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_period_title.tr()),
        onTap: () {
          tags.addAll(
            _buildFrom(LocaleKeys.seriesEdit_seriesSettings_tags_preset_period_tagNames.tr(), [
              Colors.white,
              ColorUtils.fromHex("#ecb0b2"),
              ColorUtils.fromHex("#f36e71"),
              ColorUtils.fromHex("#ec3a5a"),
              ColorUtils.fromHex("#9c1020"),
            ]),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_stars_title.tr()),
        onTap: () {
          tags.addAll(
            List<Tag>.generate(
              5,
              (index) => Tag(
                tagId: Tag.generateUniqueTagId(val: now - index),
                color: ColorUtils.hue(const Color(0xF5FFAA00), 25.0 * index),
                name: "".padLeft(index + 1, '★'),
              ),
            ).reversed,
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_stress_title.tr()),
        onTap: () {
          tags.addAll(
            List<Tag>.generate(
              5,
              (index) => Tag(
                tagId: Tag.generateUniqueTagId(val: now - index),
                color: ColorUtils.hue(ColorUtils.fromHex('996726'), -30.0 * index),
                name: "".padLeft(index + 1, '☠'),
              ),
            ),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_colorWheel_title.tr()),
        onTap: () {
          tags.addAll(
            List<Tag>.generate(
              12,
              (index) => Tag(
                tagId: Tag.generateUniqueTagId(val: now - index),
                color: ColorUtils.hue(Colors.green, -30.0 * index),
                name: "",
              ),
            ),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_hoursDown_title.tr()),
        onTap: () {
          tags.addAll(
            List<Tag>.generate(
              8,
              (index) => Tag(
                tagId: Tag.generateUniqueTagId(val: now - index),
                color: ColorUtils.hue(Colors.lightBlueAccent, 20.0 * (index)),
                name: "${index >= 7 ? '>= ' : ''}${index + 1} h",
              ),
            ),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_hoursUp_title.tr()),
        onTap: () {
          tags.addAll(
            List<Tag>.generate(
              8,
              (index) => Tag(
                tagId: Tag.generateUniqueTagId(val: now - index),
                color: ColorUtils.hue(Colors.lightBlueAccent, -15.0 * (index)),
                name: "${index >= 7 ? '>= ' : ''}${index + 1} h",
              ),
            ).reversed,
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_minutesDown_title.tr()),
        onTap: () {
          tags.addAll(
            List<Tag>.generate(
              6,
              (index) => Tag(
                tagId: Tag.generateUniqueTagId(val: now - index),
                color: ColorUtils.hue(Colors.lightBlueAccent, 20.0 * (index)),
                name: "${index >= 5 ? '>= ' : ''}${(index + 1) * 10} min",
              ),
            ),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_minutesUp_title.tr()),
        onTap: () {
          tags.addAll(
            List<Tag>.generate(
              6,
              (index) => Tag(
                tagId: Tag.generateUniqueTagId(val: now - index),
                color: ColorUtils.hue(Colors.lightBlueAccent, -15.0 * (index)),
                name: "${index >= 5 ? '>= ' : ''}${(index + 1) * 10} min",
              ),
            ).reversed,
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_numbersDown_title.tr()),
        onTap: () {
          tags.addAll(
            List<Tag>.generate(
              10,
              (index) => Tag(
                tagId: Tag.generateUniqueTagId(val: now - index),
                color: ColorUtils.hue(Colors.lightGreenAccent, -20.0 * (index)),
                name: "${index >= 9 ? '>= ' : ''}${index + 1}",
              ),
            ),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_tags_preset_numbersUp_title.tr()),
        onTap: () {
          tags.addAll(
            List<Tag>.generate(
              10,
              (index) => Tag(
                tagId: Tag.generateUniqueTagId(val: now - index),
                color: ColorUtils.hue(Colors.lightGreenAccent, 10.0 * (index)),
                name: "${index >= 9 ? '>= ' : ''}${index + 1}",
              ),
            ).reversed,
          );
          updateSettings();
        },
      ),
    ];
  }

  static List<Tag> _buildFrom(String tagNames, List<Color> colors) {
    var now = DateTime.now().millisecondsSinceEpoch;
    List<Tag> result = [];

    var split = tagNames.split("|");
    for (var i = 0; i < split.length; ++i) {
      var tagName = split[i];
      Color tagColor = colors.elementAtOrNull(i) ?? ColorUtils.hue(Colors.greenAccent, 17.0 * i);
      result.add(
        Tag(
          tagId: Tag.generateUniqueTagId(val: now - i),
          color: tagColor,
          name: tagName,
        ),
      );
    }

    return result;
  }
}
