import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/tags/tag.dart';
import '../../../util/theme_utils.dart';
import '../../series/series_def_renderer.dart';
import '../card/glowing_border_container.dart';
import '../list/drag_handle.dart';
import 'tag_input.dart';
import 'tag_renderer.dart';

class TagEditRenderer extends StatelessWidget {
  final Tag tag;
  final int index;
  final void Function(Tag updatedTag) updateTagCB;
  final void Function(Tag deletedTag) deleteTagCB;

  const TagEditRenderer({
    super.key,
    required this.tag,
    required this.index,
    required this.updateTagCB,
    required this.deleteTagCB,
  });

  @override
  Widget build(BuildContext context) {
    return GlowingBorderContainer(
      glowColor: tag.color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: ThemeUtils.horizontalSpacing),
          // OverflowText(dailyLifeTag.name),
          Expanded(
            child: TagRenderer(tag: tag),
          ),
          const SizedBox(width: ThemeUtils.horizontalSpacing),
          LeftBorder(
            color: tag.color,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: ThemeUtils.iconSizeScaled,
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_tags_actions_edit_tooltip.tr(),
                  onPressed: () async {
                    Tag? updatedDailyLifeTag = await TagInput.showInputDlg(context, tag: tag.clone());
                    if (updatedDailyLifeTag != null) {
                      updateTagCB(updatedDailyLifeTag);
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  iconSize: ThemeUtils.iconSizeScaled,
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_tags_actions_delete_tooltip.tr(),
                  onPressed: () {
                    deleteTagCB(tag);
                  },
                  icon: const Icon(Icons.close_outlined),
                ),
              ],
            ),
          ),
          LeftBorder(
            color: tag.color,
            child: Row(
              children: [DragHandle(index: index)],
            ),
          ),
        ],
      ),
    );
  }
}
