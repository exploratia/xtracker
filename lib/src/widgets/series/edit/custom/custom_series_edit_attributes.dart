import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/attributes/attribute.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/settings/custom/custom_attributes_settings.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/attribute/attribute_edit_renderer.dart';
import '../../../controls/attribute/attribute_input.dart';
import '../../../controls/btn/info_btn.dart';

class CustomSeriesEditAttributes extends StatelessWidget {
  final SeriesDef seriesDef;
  final CustomAttributesSettings customAttributesSettings;

  const CustomSeriesEditAttributes(this.seriesDef, this.customAttributesSettings, {super.key});

  @override
  Widget build(BuildContext context) {
    var attributes = customAttributesSettings.attributes;
    List<Widget> listItems = [];

    updateSettings() => customAttributesSettings.attributes = attributes;

    for (var i = 0; i < attributes.length; ++i) {
      var attribute = attributes[i];
      var renderer = AttributeEditRenderer(
        key: Key("attribute_list_item_${attribute.aid}"),
        attribute: Attribute(aid: attribute.aid, color: attribute.color, name: attribute.name),
        index: i,
        updateAttributeCB: (Attribute updatedCustomAttribute) {
          var idx = attributes.indexWhere((a) => a.aid == updatedCustomAttribute.aid);
          if (idx >= 0) {
            attributes.replaceRange(idx, idx + 1, [updatedCustomAttribute]);
            updateSettings();
          }
        },
        deleteAttributeCB: (Attribute deletedCustomAttribute) {
          attributes.removeWhere((a) => a.aid == deletedCustomAttribute.aid);
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
            title: LocaleKeys.seriesEdit_seriesSettings_attributes_title.tr(),
            content: LocaleKeys.seriesEdit_seriesSettings_attributes_info.tr(),
          ),
          Expanded(child: Container()),
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.seriesEdit_seriesSettings_attributes_actions_add_tooltip.tr(),
            onPressed: () async {
              Attribute? customAttribute = await AttributeInput.showInputDlg(context, newAttributeColor: seriesDef.color);
              if (customAttribute != null) {
                attributes.insert(0, customAttribute);
                updateSettings();
              }
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.seriesEdit_seriesSettings_attributes_actions_deleteAll_tooltip.tr(),
            onPressed: () async {
              attributes.clear();
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
        if (attributes.length <= oldIndex || attributes.length <= newIndex) return;

        final item = attributes.removeAt(oldIndex);
        attributes.insert(newIndex, item);
        updateSettings();
      },
    );
  }
}
