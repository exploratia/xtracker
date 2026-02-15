import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/attributes/attribute.dart';
import '../../../util/theme_utils.dart';
import '../../series/series_def_renderer.dart';
import '../card/glowing_border_container.dart';
import '../list/drag_handle.dart';
import 'attribute_input.dart';
import 'attribute_renderer.dart';

class AttributeEditRenderer extends StatelessWidget {
  final Attribute attribute;
  final int index;
  final void Function(Attribute updatedAttribute) updateAttributeCB;
  final void Function(Attribute deletedAttribute) deleteAttributeCB;

  const AttributeEditRenderer({
    super.key,
    required this.attribute,
    required this.index,
    required this.updateAttributeCB,
    required this.deleteAttributeCB,
  });

  @override
  Widget build(BuildContext context) {
    return GlowingBorderContainer(
      glowColor: attribute.color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: ThemeUtils.horizontalSpacing),
          // OverflowText(dailyLifeAttribute.name),
          Expanded(
            child: AttributeRenderer(attribute: attribute),
          ),
          const SizedBox(width: ThemeUtils.horizontalSpacing),
          LeftBorder(
            color: attribute.color,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: ThemeUtils.iconSizeScaled,
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_attributes_actions_edit_tooltip.tr(),
                  onPressed: () async {
                    Attribute? updatedDailyLifeAttribute = await AttributeInput.showInputDlg(context, attribute: attribute.clone());
                    if (updatedDailyLifeAttribute != null) {
                      updateAttributeCB(updatedDailyLifeAttribute);
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  iconSize: ThemeUtils.iconSizeScaled,
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_attributes_actions_delete_tooltip.tr(),
                  onPressed: () {
                    deleteAttributeCB(attribute);
                  },
                  icon: const Icon(Icons.close_outlined),
                ),
              ],
            ),
          ),
          LeftBorder(
            color: attribute.color,
            child: Row(
              children: [DragHandle(index: index)],
            ),
          ),
        ],
      ),
    );
  }
}
