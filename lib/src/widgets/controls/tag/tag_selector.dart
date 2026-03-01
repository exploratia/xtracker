import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/tags/tag.dart';
import '../../../model/series/tags/tag_resolver.dart';
import '../../../util/media_query_utils.dart';
import '../../../util/theme_utils.dart';
import 'tag_renderer.dart';

class TagSelector extends StatelessWidget {
  final TagResolver tagResolver;
  final List<Tag> tags;
  final String? tagUuid;
  final void Function(String) handleTagUuid;
  final void Function()? deleteTagUuid;

  const TagSelector({
    super.key,
    required this.tagResolver,
    required this.tags,
    this.tagUuid,
    required this.handleTagUuid,
    this.deleteTagUuid,
  });

  @override
  Widget build(BuildContext context) {
    var tagsPopupMenuButton = PopupMenuButton(
      borderRadius: ThemeUtils.borderRadiusCircular,
      icon: tagUuid == null ? const Icon(Icons.list) : null,
      tooltip: LocaleKeys.controls_select_tag_action_select_tooltip.tr(),
      itemBuilder: (context) {
        var list = tags
            .map(
              (e) => PopupMenuItem(
                /* Flutter Bug? if right >= 10 a huge wider padding is used. Seems not to work always. If only Text-Widgets are uses as child it has no effect. */
                padding: const EdgeInsets.only(right: 9, left: 9, bottom: 0),
                onTap: () => handleTagUuid(e.tagId),
                child: TagRenderer(tag: e),
              ),
            )
            .toList();
        if (deleteTagUuid != null) {
          list.add(
            PopupMenuItem(
              padding: const EdgeInsets.only(right: 9, left: 9, bottom: 0),
              onTap: deleteTagUuid,
              child: Tooltip(
                message: LocaleKeys.controls_select_tag_action_clear_tooltip.tr(),
                child: const Center(child: Icon(Icons.clear_outlined)),
              ),
            ),
          );
        }
        return list;
      },
      child: tagUuid != null
          ? Padding(
              padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
              child: TagRenderer(tag: tagResolver.resolve(tagUuid)),
            )
          : null,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 48 * MediaQueryUtils.textScaleFactor),
      child: Center(
        child: tagsPopupMenuButton,
      ),
    );
  }
}
