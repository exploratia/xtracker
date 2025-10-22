import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_def.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/card/glowing_border_container.dart';
import '../../../controls/list/drag_handle.dart';
import '../../../controls/text/overflow_text.dart';
import '../../series_def_renderer.dart';
import 'series_item_input.dart';

class SeriesItemsEdit extends StatelessWidget {
  final SeriesDef seriesDef;
  final Function() updateStateCB;

  const SeriesItemsEdit(this.seriesDef, this.updateStateCB, {super.key});

  @override
  Widget build(BuildContext context) {
    var seriesItems = seriesDef.seriesItems;
    List<Widget> listItems = [];

    updateSettings() => updateStateCB();

    for (var i = 0; i < seriesItems.length; ++i) {
      var attribute = seriesItems[i];
      var renderer = _SeriesItemRenderer(
        key: Key("series_item_${attribute.siid}"),
        seriesItem: SeriesItem(siid: attribute.siid, color: attribute.color, name: attribute.name, unit: attribute.unit),
        index: i,
        updateSeriesItemCB: (SeriesItem updatedSeriesItem) {
          var idx = seriesItems.indexWhere((a) => a.siid == updatedSeriesItem.siid);
          if (idx >= 0) {
            seriesItems.replaceRange(idx, idx + 1, [updatedSeriesItem]);
            updateSettings();
          }
        },
        deleteSeriesItemCB: (SeriesItem deletedSeriesItem) {
          seriesItems.removeWhere((a) => a.siid == deletedSeriesItem.siid);
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
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.commons_btn_info_tooltip.tr(),
            onPressed: () async {
              Dialogs.simpleOkDialog(
                LocaleKeys.seriesEdit_seriesSettings_seriesItems_info.tr(),
                context,
                title: LocaleKeys.seriesEdit_seriesSettings_seriesItems_title.tr(),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
          Expanded(child: Container()),
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_actions_add_tooltip.tr(),
            onPressed: () async {
              SeriesItem? seriesItem = await SeriesItemInput.showInputDlg(context, newSeriesItemColor: seriesDef.color);
              if (seriesItem != null) {
                seriesItems.insert(0, seriesItem);
                updateSettings();
              }
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_actions_deleteAll_tooltip.tr(),
            onPressed: () async {
              seriesItems.clear();
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
        if (seriesItems.length <= oldIndex || seriesItems.length <= newIndex) return;

        final item = seriesItems.removeAt(oldIndex);
        seriesItems.insert(newIndex, item);
        updateSettings();
      },
    );
  }
}

class _SeriesItemRenderer extends StatelessWidget {
  final SeriesItem seriesItem;
  final int index;
  final void Function(SeriesItem updatedSeriesItem) updateSeriesItemCB;
  final void Function(SeriesItem deletedSeriesItem) deleteSeriesItemCB;

  const _SeriesItemRenderer({
    super.key,
    required this.seriesItem,
    required this.index,
    required this.updateSeriesItemCB,
    required this.deleteSeriesItemCB,
  });

  @override
  Widget build(BuildContext context) {
    return GlowingBorderContainer(
      glowColor: seriesItem.color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: ThemeUtils.horizontalSpacing),
          Expanded(
            child: OverflowText('${seriesItem.name} [${seriesItem.unit}]', expanded: false),
          ),
          const SizedBox(width: ThemeUtils.horizontalSpacing),
          LeftBorder(
            color: seriesItem.color,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: ThemeUtils.iconSizeScaled,
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_actions_edit_tooltip.tr(),
                  onPressed: () async {
                    SeriesItem? updatedSeriesItem = await SeriesItemInput.showInputDlg(context, seriesItem: seriesItem.clone());
                    if (updatedSeriesItem != null) {
                      updateSeriesItemCB(updatedSeriesItem);
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  iconSize: ThemeUtils.iconSizeScaled,
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_actions_delete_tooltip.tr(),
                  onPressed: () {
                    deleteSeriesItemCB(seriesItem);
                  },
                  icon: const Icon(Icons.close_outlined),
                ),
              ],
            ),
          ),
          LeftBorder(
            color: seriesItem.color,
            child: Row(
              children: [DragHandle(index: index)],
            ),
          ),
        ],
      ),
    );
  }
}
