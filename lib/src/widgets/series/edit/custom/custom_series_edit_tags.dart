import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/settings/custom/custom_tags_settings.dart';
import '../../../../model/series/tags/tag.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/btn/info_btn.dart';
import '../../../controls/tag/tag_edit_renderer.dart';
import '../../../controls/tag/tag_input.dart';

class CustomSeriesEditTags extends StatelessWidget {
  final SeriesDef seriesDef;
  final CustomTagsSettings customTagsSettings;

  const CustomSeriesEditTags(this.seriesDef, this.customTagsSettings, {super.key});

  @override
  Widget build(BuildContext context) {
    var tags = customTagsSettings.tags;
    List<Widget> listItems = [];

    updateSettings() => customTagsSettings.tags = tags;

    for (var i = 0; i < tags.length; ++i) {
      var tag = tags[i];
      var renderer = TagEditRenderer(
        key: Key("tag_list_item_${tag.tagId}"),
        tag: Tag(tagId: tag.tagId, color: tag.color, name: tag.name),
        index: i,
        updateTagCB: (Tag updatedCustomTag) {
          var idx = tags.indexWhere((a) => a.tagId == updatedCustomTag.tagId);
          if (idx >= 0) {
            tags.replaceRange(idx, idx + 1, [updatedCustomTag]);
            updateSettings();
          }
        },
        deleteTagCB: (Tag deletedCustomTag) {
          tags.removeWhere((a) => a.tagId == deletedCustomTag.tagId);
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
              Tag? customTag = await TagInput.showInputDlg(context, newTagColor: seriesDef.color);
              if (customTag != null) {
                tags.insert(0, customTag);
                updateSettings();
              }
            },
            icon: const Icon(Icons.add),
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
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        if (tags.length <= oldIndex || tags.length <= newIndex) return;

        final item = tags.removeAt(oldIndex);
        tags.insert(newIndex, item);
        updateSettings();
      },
    );
  }
}
