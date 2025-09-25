import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/settings/daily_life/daily_life_attribute.dart';
import '../../../../model/series/settings/daily_life/daily_life_attributes_settings.dart';
import '../../../../util/color_utils.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/card/glowing_border_container.dart';
import '../../../controls/list/drag_handle.dart';
import '../../data/view/daily_life/daily_life_attribute_renderer.dart';
import '../../series_def_renderer.dart';
import 'daily_life_attribute_input.dart';

class DailyLifeSeriesEditAttributes extends StatelessWidget {
  final SeriesDef seriesDef;
  final DailyLifeAttributesSettings dailyLifeAttributesSettings;

  const DailyLifeSeriesEditAttributes(this.seriesDef, this.dailyLifeAttributesSettings, {super.key});

  @override
  Widget build(BuildContext context) {
    var attributes = dailyLifeAttributesSettings.attributes;
    List<Widget> listItems = [];

    updateSettings() => dailyLifeAttributesSettings.attributes = attributes;

    for (var i = 0; i < attributes.length; ++i) {
      var attribute = attributes[i];
      var renderer = _AttributeRenderer(
        key: Key("attribute_list_item_${attribute.aid}"),
        dailyLifeAttribute: DailyLifeAttribute(aid: attribute.aid, color: attribute.color, name: attribute.name),
        index: i,
        updateAttributeCB: (DailyLifeAttribute updatedDailyLifeAttribute) {
          var idx = attributes.indexWhere((a) => a.aid == updatedDailyLifeAttribute.aid);
          if (idx >= 0) {
            attributes.replaceRange(idx, idx + 1, [updatedDailyLifeAttribute]);
            updateSettings();
          }
        },
        deleteAttributeCB: (DailyLifeAttribute deletedDailyLifeAttribute) {
          attributes.removeWhere((a) => a.aid == deletedDailyLifeAttribute.aid);
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
          IconButton(
            tooltip: LocaleKeys.commons_btn_info_tooltip.tr(),
            onPressed: () async {
              Dialogs.simpleOkDialog(
                LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_info.tr(),
                context,
                title: LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_title.tr(),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
          Expanded(child: Container()),
          IconButton(
            tooltip: LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_actions_add_tooltip.tr(),
            onPressed: () async {
              DailyLifeAttribute? dailyLifeAttribute = await DailyLifeAttributeInput.showInputDlg(context, newAttributeColor: seriesDef.color);
              if (dailyLifeAttribute != null) {
                attributes.insert(0, dailyLifeAttribute);
                updateSettings();
              }
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton(
            borderRadius: ThemeUtils.borderRadiusCircular,
            icon: const Icon(Icons.playlist_add_outlined),
            tooltip: LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_actions_addPreset_tooltip.tr(),
            itemBuilder: (context) => _buildPresets(attributes, updateSettings),
          ),
          IconButton(
            tooltip: LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_actions_deleteAll_tooltip.tr(),
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

  List<PopupMenuItem<dynamic>> _buildPresets(List<DailyLifeAttribute> attributes, List<DailyLifeAttribute> Function() updateSettings) {
    int now = DateTime.now().millisecondsSinceEpoch;
    return [
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_feelings_title.tr()),
        onTap: () {
          attributes.addAll(_buildFrom(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_feelings_attributeNames.tr(), [
            ColorUtils.fromHex("#cb2526"),
            ColorUtils.fromHex("#ef8110"),
            ColorUtils.fromHex("#e6ca4a"),
            ColorUtils.fromHex("#5bab4a"),
            ColorUtils.fromHex("#557d75"),
            ColorUtils.fromHex("#649bd8"),
            ColorUtils.fromHex("#0c155a"),
            ColorUtils.fromHex("#9a457e"),
            ColorUtils.fromHex("#303030"),
          ]));
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_sports_title.tr()),
        onTap: () {
          attributes.addAll(_buildFrom(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_sports_attributeNames.tr(), [
            Colors.orangeAccent,
            Colors.deepOrange,
            Colors.lightGreenAccent,
            Colors.blueGrey,
            Colors.green,
            Colors.blueAccent,
            Colors.purple,
          ]));
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_period_title.tr()),
        onTap: () {
          attributes.addAll(_buildFrom(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_period_attributeNames.tr(), [
            Colors.white,
            ColorUtils.fromHex("#ecb0b2"),
            ColorUtils.fromHex("#f36e71"),
            ColorUtils.fromHex("#ec3a5a"),
            ColorUtils.fromHex("#9c1020"),
          ]));
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_stars_title.tr()),
        onTap: () {
          attributes.addAll(
            List<DailyLifeAttribute>.generate(
              5,
              (index) => DailyLifeAttribute(
                aid: DailyLifeAttribute.generateUniqueAttributeId(val: now - index),
                color: ColorUtils.hue(const Color(0xF5FFAA00), 25.0 * index),
                name: "".padLeft(index + 1, '★'),
              ),
            ).reversed,
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_stress_title.tr()),
        onTap: () {
          attributes.addAll(
            List<DailyLifeAttribute>.generate(
              5,
              (index) => DailyLifeAttribute(
                aid: DailyLifeAttribute.generateUniqueAttributeId(val: now - index),
                color: ColorUtils.hue(ColorUtils.fromHex('996726'), -30.0 * index),
                name: "".padLeft(index + 1, '☠'),
              ),
            ),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_colorWheel_title.tr()),
        onTap: () {
          attributes.addAll(
            List<DailyLifeAttribute>.generate(
              12,
              (index) => DailyLifeAttribute(
                aid: DailyLifeAttribute.generateUniqueAttributeId(val: now - index),
                color: ColorUtils.hue(Colors.green, -30.0 * index),
                name: "",
              ),
            ),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_hoursDown_title.tr()),
        onTap: () {
          attributes.addAll(
            List<DailyLifeAttribute>.generate(
              8,
              (index) => DailyLifeAttribute(
                aid: DailyLifeAttribute.generateUniqueAttributeId(val: now - index),
                color: ColorUtils.hue(Colors.lightBlueAccent, 20.0 * (index)),
                name: "${index >= 7 ? '>= ' : ''}${index + 1} h",
              ),
            ),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_hoursUp_title.tr()),
        onTap: () {
          attributes.addAll(
            List<DailyLifeAttribute>.generate(
              8,
              (index) => DailyLifeAttribute(
                aid: DailyLifeAttribute.generateUniqueAttributeId(val: now - index),
                color: ColorUtils.hue(Colors.lightBlueAccent, -15.0 * (index)),
                name: "${index >= 7 ? '>= ' : ''}${index + 1} h",
              ),
            ).reversed,
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_minutesDown_title.tr()),
        onTap: () {
          attributes.addAll(
            List<DailyLifeAttribute>.generate(
              6,
              (index) => DailyLifeAttribute(
                aid: DailyLifeAttribute.generateUniqueAttributeId(val: now - index),
                color: ColorUtils.hue(Colors.lightBlueAccent, 20.0 * (index)),
                name: "${index >= 5 ? '>= ' : ''}${(index + 1) * 10} min",
              ),
            ),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_minutesUp_title.tr()),
        onTap: () {
          attributes.addAll(
            List<DailyLifeAttribute>.generate(
              6,
              (index) => DailyLifeAttribute(
                aid: DailyLifeAttribute.generateUniqueAttributeId(val: now - index),
                color: ColorUtils.hue(Colors.lightBlueAccent, -15.0 * (index)),
                name: "${index >= 5 ? '>= ' : ''}${(index + 1) * 10} min",
              ),
            ).reversed,
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_numbersDown_title.tr()),
        onTap: () {
          attributes.addAll(
            List<DailyLifeAttribute>.generate(
              10,
              (index) => DailyLifeAttribute(
                aid: DailyLifeAttribute.generateUniqueAttributeId(val: now - index),
                color: ColorUtils.hue(Colors.lightGreenAccent, -20.0 * (index)),
                name: "${index >= 9 ? '>= ' : ''}${index + 1}",
              ),
            ),
          );
          updateSettings();
        },
      ),
      PopupMenuItem(
        child: Text(LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_preset_numbersUp_title.tr()),
        onTap: () {
          attributes.addAll(
            List<DailyLifeAttribute>.generate(
              10,
              (index) => DailyLifeAttribute(
                aid: DailyLifeAttribute.generateUniqueAttributeId(val: now - index),
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

  static List<DailyLifeAttribute> _buildFrom(String attributeNames, List<Color> colors) {
    var now = DateTime.now().millisecondsSinceEpoch;
    List<DailyLifeAttribute> result = [];

    var split = attributeNames.split("|");
    for (var i = 0; i < split.length; ++i) {
      var attributeName = split[i];
      Color attributeColor = colors.elementAtOrNull(i) ?? ColorUtils.hue(Colors.greenAccent, 17.0 * i);
      result.add(DailyLifeAttribute(
        aid: DailyLifeAttribute.generateUniqueAttributeId(val: now - i),
        color: attributeColor,
        name: attributeName,
      ));
    }

    return result;
  }
}

class _AttributeRenderer extends StatelessWidget {
  final DailyLifeAttribute dailyLifeAttribute;
  final int index;
  final void Function(DailyLifeAttribute updatedDailyLifeAttribute) updateAttributeCB;
  final void Function(DailyLifeAttribute deletedDailyLifeAttribute) deleteAttributeCB;

  const _AttributeRenderer({
    super.key,
    required this.dailyLifeAttribute,
    required this.index,
    required this.updateAttributeCB,
    required this.deleteAttributeCB,
  });

  @override
  Widget build(BuildContext context) {
    return GlowingBorderContainer(
      glowColor: dailyLifeAttribute.color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: ThemeUtils.horizontalSpacing),
          // OverflowText(dailyLifeAttribute.name),
          Expanded(
            child: DailyLifeAttributeRenderer(dailyLifeAttribute: dailyLifeAttribute),
          ),
          const SizedBox(width: ThemeUtils.horizontalSpacing),
          LeftBorder(
            color: dailyLifeAttribute.color,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_actions_edit_tooltip.tr(),
                  onPressed: () async {
                    DailyLifeAttribute? updatedDailyLifeAttribute =
                        await DailyLifeAttributeInput.showInputDlg(context, dailyLifeAttribute: dailyLifeAttribute.clone());
                    if (updatedDailyLifeAttribute != null) {
                      updateAttributeCB(updatedDailyLifeAttribute);
                    }
                  },
                  iconSize: ThemeUtils.iconSizeScaled,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_dailyLifeAttributes_actions_delete_tooltip.tr(),
                  onPressed: () {
                    deleteAttributeCB(dailyLifeAttribute);
                  },
                  iconSize: ThemeUtils.iconSizeScaled,
                  icon: const Icon(Icons.close_outlined),
                ),
              ],
            ),
          ),
          LeftBorder(
            color: dailyLifeAttribute.color,
            child: Row(
              children: [DragHandle(index: index)],
            ),
          ),
        ],
      ),
    );
  }
}
