import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/seriesItem/series_item.dart';
import '../../../../model/series/series_def.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/media_query_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/appbar/app_bar_actions_divider.dart';
import '../../../controls/btn/info_btn.dart';
import '../../../controls/card/glowing_border_container.dart';
import '../../../controls/list/drag_handle.dart';
import '../../../controls/text/overflow_text.dart';
import '../../series_def_renderer.dart';
import 'series_item_input.dart';
import 'series_items_chart_settings.dart';
import 'series_items_table_settings.dart';

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
      var seriesItem = seriesItems[i];
      var renderer = _SeriesItemRenderer(
        key: Key("series_item_${seriesItem.siid}"),
        seriesItem: seriesItem,
        seriesItems: seriesItems,
        index: i,
        editSeriesItemCB: () async {
          SeriesItem? updatedSeriesItem = await SeriesItemInput.showInputDlg(context, seriesItem: seriesItem.clone(), seriesDef: seriesDef);
          if (updatedSeriesItem != null) {
            var idx = seriesItems.indexWhere((a) => a.siid == updatedSeriesItem.siid);
            if (idx >= 0) {
              seriesItems.replaceRange(idx, idx + 1, [updatedSeriesItem]);
              updateSettings();
            }
          }
        },
        deleteSeriesItemCB: () async {
          List<String> referencingCalculatedSeriesItems = [];
          for (var checkItem in seriesItems) {
            if (checkItem.references(seriesItem.siid)) {
              referencingCalculatedSeriesItems.add(checkItem.siid);
            }
          }
          if (referencingCalculatedSeriesItems.isEmpty) {
            seriesItems.removeWhere((si) => si.siid == seriesItem.siid);
            updateSettings();
          } else {
            bool? deleteWithReferences = await Dialogs.simpleYesNoDialog(
              LocaleKeys.seriesEdit_seriesSettings_seriesItems_actions_delete_query_deleteWithReferencingItems.tr(),
              context,
            );
            if (deleteWithReferences == true) {
              seriesItems.removeWhere((si) => si.siid == seriesItem.siid || referencingCalculatedSeriesItems.contains(si.siid));
              updateSettings();
            }
          }
        },
      );
      listItems.add(renderer);
    }

    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      header: LayoutBuilder(
        builder: (context, constraints) {
          var infoBtn = InfoBtn(
            title: LocaleKeys.seriesEdit_seriesSettings_seriesItems_title.tr(),
            content: LocaleKeys.seriesEdit_seriesSettings_seriesItems_info.tr(),
          );

          var headerActions = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (listItems.isNotEmpty) ...[
                IconButton(
                  iconSize: ThemeUtils.iconSizeScaled,
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_actions_editChartSettings_tooltip.tr(),
                  onPressed: () async {
                    var updatedSeriesItems = await SeriesItemsChartSettings.showInputDlg(context, seriesItems: seriesItems);
                    if (updatedSeriesItems != null) {
                      seriesItems.clear();
                      seriesItems.addAll(updatedSeriesItems);
                      updateSettings();
                    }
                  },
                  icon: const Icon(Icons.line_axis_outlined),
                ),
                IconButton(
                  iconSize: ThemeUtils.iconSizeScaled,
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_actions_editTableSettings_tooltip.tr(),
                  onPressed: () async {
                    var updatedSeriesItems = await SeriesItemsTableSettings.showInputDlg(context, seriesItems: seriesItems);
                    if (updatedSeriesItems != null) {
                      seriesItems.clear();
                      seriesItems.addAll(updatedSeriesItems);
                      updateSettings();
                    }
                  },
                  icon: const Icon(Icons.view_column_outlined),
                ),
                const SizedBox(height: 40, child: AppBarActionsDivider()),
              ],
              IconButton(
                iconSize: ThemeUtils.iconSizeScaled,
                tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_actions_add_tooltip.tr(),
                onPressed: () async {
                  SeriesItem? seriesItem = await SeriesItemInput.showInputDlg(context, seriesDef: seriesDef);
                  if (seriesItem != null) {
                    seriesItems.insert(0, seriesItem);
                    updateSettings();
                  }
                },
                icon: const Icon(Icons.add),
              ),
              if (seriesItems.isNotEmpty)
                IconButton(
                  iconSize: ThemeUtils.iconSizeScaled,
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_actions_addCalculated_tooltip.tr(),
                  onPressed: () async {
                    SeriesItem? seriesItem = await SeriesItemInput.showInputDlg(context, createCalculatedItem: true, seriesDef: seriesDef);
                    if (seriesItem != null) {
                      seriesItems.insert(0, seriesItem);
                      updateSettings();
                    }
                  },
                  icon: SizedBox(
                    height: ThemeUtils.iconSizeScaled,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 0,
                          left: -5,
                          child: Icon(Icons.add_outlined, size: ThemeUtils.iconSizeScaled),
                        ),
                        Positioned(
                          right: -1,
                          top: -3,
                          child: Icon(Icons.link_outlined, size: 15 * MediaQueryUtils.iconScaleFactor),
                        ),
                      ],
                    ),
                  ),
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
          );

          if (constraints.maxWidth < 300) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: ThemeUtils.horizontalSpacingLarge,
              children: [
                infoBtn,
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: headerActions,
                  ),
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              infoBtn,
              headerActions,
            ],
          );
        },
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
  final List<SeriesItem> seriesItems;
  final int index;
  final void Function() editSeriesItemCB;
  final void Function() deleteSeriesItemCB;

  /// -[seriesItems] readonly!
  const _SeriesItemRenderer({
    super.key,
    required this.seriesItem,
    required this.index,
    required this.editSeriesItemCB,
    required this.deleteSeriesItemCB,
    required this.seriesItems,
  });

  @override
  Widget build(BuildContext context) {
    Widget widget = GlowingBorderContainer(
      glowColor: seriesItem.color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: ThemeUtils.horizontalSpacing),
          Expanded(
            child: OverflowText('${seriesItem.name}${seriesItem.unitInBrackets()}', expanded: false),
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
                  onPressed: editSeriesItemCB,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  iconSize: ThemeUtils.iconSizeScaled,
                  tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_actions_delete_tooltip.tr(),
                  onPressed: deleteSeriesItemCB,
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

    if (seriesItem.isCalculated) {
      widget = Row(
        spacing: ThemeUtils.horizontalSpacingSmall,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.link_outlined,
            size: ThemeUtils.iconSizeScaled,
          ),
          Expanded(child: widget),
        ],
      );
    }

    return widget;
  }
}
