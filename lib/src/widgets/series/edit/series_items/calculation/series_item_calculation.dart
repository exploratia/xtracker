import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_container.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_item.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_item_numeric.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_item_series_value.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_operator.dart';
import '../../../../../model/series/seriesItem/series_item.dart';
import '../../../../../util/chart/chart_utils.dart';
import '../../../../../util/logging/flutter_simple_logging.dart';
import '../../../../../util/theme_utils.dart';
import 'calculation_container_input.dart';
import 'calculation_item_input.dart';
import 'calculation_series_item_renderer.dart';

class SeriesItemCalculation extends StatefulWidget {
  final CalculationContainer? calculationContainer;
  final List<SeriesItem> availableSeriesItems;
  final void Function(CalculationContainer calculationContainer) setCalculationContainer;

  const SeriesItemCalculation({super.key, this.calculationContainer, required this.availableSeriesItems, required this.setCalculationContainer});

  @override
  State<SeriesItemCalculation> createState() => _SeriesItemCalculationState();
}

class _SeriesItemCalculationState extends State<SeriesItemCalculation> {
  _IndexPos? _selectedIndexPos;

  void _setSelectedIndexPos(_IndexPos? selected) {
    setState(() {
      _selectedIndexPos = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.calculationContainer == null) {
      return Center(
        child: IconButton(
          tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_btn_selectFirstSeriesItem_tooltip.tr(),
          onPressed: () async {
            var result = await CalculationContainerInput.showInputDlg(context, existingSeriesItems: widget.availableSeriesItems);
            if (result != null) widget.setCalculationContainer(result);
          },
          icon: Icon(
            Icons.add_link_outlined,
            size: ThemeUtils.iconSizeScaled,
          ),
        ),
      );
    }

    List<Widget> calcWidgets = [];
    _buildCalcWidgets(widget.calculationContainer, _IndexPos([]), 0, calcWidgets);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: calcWidgets,
    );
  }

  /// resolve CalculationContainer - root or from calculation item
  CalculationContainer? _resolveCalculationContainer(_IndexPos indexPos) {
    if (widget.calculationContainer == null) {
      SimpleLogging.e("_resolveCalculationContainer called without calculation root set!");
      return null;
    }
    var result = widget.calculationContainer!;
    if (indexPos.isRoot) return result;

    for (var idx in indexPos.idxPath) {
      var calculationItem = result.calculationItems[idx];
      if (calculationItem is CalculationItemSeriesValue) {
        result = calculationItem.calculationContainer;
      } else {
        SimpleLogging.e("Got unexpected $indexPos in _resolveCalculationContainer!");
        return null;
      }
    }

    return result;
  }

  /// resolve calculation item for index pos - must not be root
  CalculationItem? _resolveCalculationItem(_IndexPos indexPos) {
    if (widget.calculationContainer == null) {
      SimpleLogging.e("_resolveCalculationContainer called without calculation root set!");
      return null;
    }
    if (indexPos.isRoot) {
      SimpleLogging.e("_resolveCalculationContainer called for root!");
      return null;
    }

    var rootContainer = widget.calculationContainer!;

    CalculationItem? result;
    for (var idx in indexPos.idxPath) {
      if (result == null) {
        result = rootContainer.calculationItems[idx];
      } else if (result is CalculationItemSeriesValue) {
        result = result.calculationContainer.calculationItems[idx];
      } else {
        SimpleLogging.e("Got unexpected $indexPos in _resolveCalculationContainer!");
        return null;
      }
    }

    return result;
  }

  /// Returns the list of CalculationItems, in which indexPos resides
  List<CalculationItem>? _determineContainingCalculationItems(_IndexPos indexPos) {
    if (widget.calculationContainer == null) {
      SimpleLogging.e("_determineContainingCalculationItems called without calculation root set!");
      return null;
    }
    if (indexPos.isRoot) {
      SimpleLogging.e("_determineContainingCalculationItems called for root!");
      return null;
    }

    var rootContainer = widget.calculationContainer!;

    List<int> idxList = [...indexPos.idxPath];
    int actIdx = idxList.removeAt(0);

    // idxList already empty -> search finished
    if (idxList.isEmpty) {
      return rootContainer.calculationItems;
    }

    CalculationItem calculationItem = rootContainer.calculationItems[actIdx];

    while (idxList.isNotEmpty) {
      if (calculationItem is CalculationItemSeriesValue) {
        actIdx = idxList.removeAt(0);

        // idxList now empty -> search finished
        if (idxList.isEmpty) {
          return calculationItem.calculationContainer.calculationItems;
        }

        calculationItem = calculationItem.calculationContainer.calculationItems[actIdx];
      } else {
        SimpleLogging.e("_replaceCalculationItem called with unexpected $indexPos!");
        return null;
      }
    }

    return null;
  }

  Future<void> _editItem(_IndexPos indexPos) async {
    // root item?
    if (indexPos.isRoot) {
      var result = await CalculationContainerInput.showInputDlg(
        context,
        existingSeriesItems: widget.availableSeriesItems,
        calculationContainer: widget.calculationContainer,
      );
      if (result != null) {
        widget.setCalculationContainer(result);
        setState(() {});
      }
    } else {
      var calculationItem = _resolveCalculationItem(indexPos);
      if (calculationItem != null) {
        var result = await CalculationItemInput.showInputDlg(
          context,
          existingSeriesItems: widget.availableSeriesItems,
          calculationItem: calculationItem,
        );
        if (result != null) {
          _replaceCalculationItem(indexPos, result);
          setState(() {});
        }
      } else {
        SimpleLogging.e("Failed to resolve calculation item for $indexPos");
      }
    }
  }

  void _replaceCalculationItem(_IndexPos indexPos, CalculationItem replacement) {
    var calculationItems = _determineContainingCalculationItems(indexPos);
    if (calculationItems == null) return;

    int itemIdx = indexPos.last;
    calculationItems.replaceRange(itemIdx, itemIdx + 1, [replacement]);
    setState(() {});
  }

  void _deleteCalculationItem(_IndexPos indexPos) {
    var calculationItems = _determineContainingCalculationItems(indexPos);
    if (calculationItems == null) return;

    int itemIdx = indexPos.last;
    calculationItems.removeAt(itemIdx);
    setState(() {});
  }

  void _moveCalculationItem(_IndexPos indexPos, bool moveUp) {
    var calculationItems = _determineContainingCalculationItems(indexPos);
    if (calculationItems == null) return;

    int itemIdx = indexPos.last;

    if (moveUp) {
      var replacements = [
        ...[...calculationItems.getRange(itemIdx - 1, itemIdx + 1)].reversed
      ];
      calculationItems.replaceRange(itemIdx - 1, itemIdx + 1, replacements);
      _setSelectedIndexPos(indexPos.replaceLast(itemIdx - 1));
    } else {
      var replacements = [
        ...[...calculationItems.getRange(itemIdx, itemIdx + 2)].reversed
      ];
      calculationItems.replaceRange(itemIdx, itemIdx + 2, replacements);
      _setSelectedIndexPos(indexPos.replaceLast(itemIdx + 1));
    }
  }

  Future<void> _addCalculationItem(_IndexPos indexPos) async {
    var result = await CalculationItemInput.showInputDlg(
      context,
      existingSeriesItems: widget.availableSeriesItems,
      calculationItem: null,
    );
    if (result != null) {
      var container = _resolveCalculationContainer(indexPos);
      if (container != null) {
        container.addCalculationItem(result);
        setState(() {});
      } else {
        SimpleLogging.e("Failed to resolve calculation container for $indexPos");
      }
    }
  }

  void _actionCallback(_IndexPos indexPos, _Action action) async {
    switch (action) {
      case _Action.select:
        _setSelectedIndexPos(indexPos);
      case _Action.deselect:
        _setSelectedIndexPos(null);
      case _Action.edit:
        await _editItem(indexPos);
      case _Action.delete:
        _deleteCalculationItem(indexPos);
      case _Action.moveUp:
        _moveCalculationItem(indexPos, true);
      case _Action.moveDown:
        _moveCalculationItem(indexPos, false);
      case _Action.add:
        await _addCalculationItem(indexPos);
    }
  }

  void _buildCalcWidgets(dynamic calcEl, _IndexPos indexedPos, int numSiblings, List<Widget> calcWidgets) {
    if (calcEl is CalculationContainer || calcEl is CalculationItemSeriesValue) {
      List<CalculationItem> calculationItems;
      if (calcEl is CalculationContainer) {
        calcWidgets.add(_CalculationInputRow(
          indexedPos: indexedPos,
          selected: indexedPos == _selectedIndexPos,
          numItems: 0,
          actionCallback: (_IndexPos indexPos, _Action action) => _actionCallback(indexPos, action),
          child: CalculationSeriesItemRenderer(
            seriesItem: widget.availableSeriesItems.firstWhere((e) => e.siid == calcEl.sourceSiid),
            usePreviousInput: calcEl.usePreviousInput,
          ),
        ));
        calculationItems = calcEl.calculationItems;
      } else if (calcEl is CalculationItemSeriesValue) {
        var calcContainer = calcEl.calculationContainer;
        calcWidgets.add(_CalculationInputRow(
          indexedPos: indexedPos,
          selected: indexedPos == _selectedIndexPos,
          numItems: numSiblings,
          actionCallback: (_IndexPos indexPos, _Action action) => _actionCallback(indexPos, action),
          operator: calcEl.operator,
          child: CalculationSeriesItemRenderer(
            seriesItem: widget.availableSeriesItems.firstWhere((e) => e.siid == calcContainer.sourceSiid),
            usePreviousInput: calcContainer.usePreviousInput,
          ),
        ));
        calculationItems = calcEl.calculationContainer.calculationItems;
      } else {
        // must not happen
        SimpleLogging.e("Unexpected item type ${calcEl.runtimeType}");
        return;
      }

      // recursive call for items
      for (var i = 0; i < calculationItems.length; ++i) {
        _buildCalcWidgets(calculationItems[i], indexedPos.append(i), calculationItems.length, calcWidgets);
      }

      calcWidgets.add(_CalculationInputRow(
        indexedPos: indexedPos,
        numItems: 0,
        isAddBtn: true,
        child: IconButton(
          tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_btn_addCalculation_tooltip.tr(),
          onPressed: () => _actionCallback(indexedPos, _Action.add),
          color: ThemeUtils.primaryColor,
          icon: Icon(
            Icons.add_box_outlined,
            size: ThemeUtils.iconSizeScaled,
          ),
        ),
      ));
    } else if (calcEl is CalculationItem) {
      if (calcEl is CalculationItemNumeric) {
        calcWidgets.add(_CalculationInputRow(
          indexedPos: indexedPos,
          selected: indexedPos == _selectedIndexPos,
          numItems: numSiblings,
          actionCallback: (_IndexPos indexPos, _Action action) => _actionCallback(indexPos, action),
          operator: calcEl.operator,
          child: Text(calcEl.value.toString()),
        ));
      } else {
        SimpleLogging.w("Unexpected calculation item '$calcEl' in calculation items!");
      }
    } else {
      SimpleLogging.w("Unexpected element '$calcEl' in calculation items!");
    }
  }
}

enum _Action {
  select,
  deselect,
  edit,
  delete,
  add,
  moveUp,
  moveDown,
}

class _CalculationInputRow extends StatelessWidget {
  final CalculationOperator? operator;
  final Widget child;
  final bool isAddBtn;
  final _IndexPos indexedPos;
  final bool selected;
  final int numItems;
  final void Function(_IndexPos indexPos, _Action)? actionCallback;

  const _CalculationInputRow({
    this.operator,
    required this.child,
    this.isAddBtn = false,
    required this.indexedPos,
    this.selected = false,
    required this.numItems,
    this.actionCallback,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> lines = [];
    for (var i = 0; i < indexedPos.length; ++i) {
      lines.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          width: 2,
          color: Colors.grey,
        ),
      ));
    }
    if (isAddBtn) {
      lines.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          width: 2,
          decoration: BoxDecoration(
            gradient: ChartUtils.createTopToBottomGradient([Colors.grey, ThemeUtils.primaryColor.withAlpha(0)]),
          ),
        ),
      ));
    }

    Widget? actions;
    if (actionCallback != null) {
      bool enableDelete = !indexedPos.isRoot;
      bool enableMoveUp = indexedPos.length > 0 && indexedPos.last > 0;
      bool enableMoveDown = !indexedPos.isRoot && indexedPos.last < numItems - 1;
      actions = IntrinsicHeight(
        child: Row(
          spacing: ThemeUtils.horizontalSpacingSmall,
          children: [
            ...lines,
            Expanded(child: Container()),
            IconButton(
              tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_action_delete_tooltip.tr(),
              onPressed: enableDelete ? () => actionCallback!(indexedPos, _Action.delete) : null,
              icon: Icon(
                Icons.delete_outline,
                size: ThemeUtils.iconSizeScaled,
              ),
            ),
            IconButton(
              tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_action_moveUp_tooltip.tr(),
              onPressed: enableMoveUp ? () => actionCallback!(indexedPos, _Action.moveUp) : null,
              icon: Icon(
                Icons.arrow_upward_outlined,
                size: ThemeUtils.iconSizeScaled,
              ),
            ),
            IconButton(
              tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_action_moveDown_tooltip.tr(),
              onPressed: enableMoveDown ? () => actionCallback!(indexedPos, _Action.moveDown) : null,
              icon: Icon(
                Icons.arrow_downward,
                size: ThemeUtils.iconSizeScaled,
              ),
            ),
            IconButton(
              tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_action_edit_tooltip.tr(),
              onPressed: () => actionCallback!(indexedPos, _Action.edit),
              icon: Icon(
                Icons.edit_outlined,
                size: ThemeUtils.iconSizeScaled,
              ),
            ),
          ],
        ),
      );
    }

    var calcRender = IntrinsicHeight(
      child: Row(
        spacing: ThemeUtils.horizontalSpacingSmall,
        children: [
          ...lines,
          if (operator != null) Text(operator!.displayName),
          Expanded(
              child: Row(
            children: [
              child,
            ],
          )),
          if (actionCallback != null)
            IconButton(
              tooltip: selected
                  ? LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_btn_deselectCalculation_tooltip.tr()
                  : LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_btn_selectCalculation_tooltip.tr(),
              onPressed: () => actionCallback!(indexedPos, selected ? _Action.deselect : _Action.select),
              icon: Icon(
                selected ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                size: ThemeUtils.iconSizeScaled,
              ),
            ),
        ],
      ),
    );

    if (actions == null || !selected) return calcRender;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        calcRender,
        actions,
      ],
    );
  }
}

class _IndexPos {
  final List<int> idxPath;

  _IndexPos(this.idxPath);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _IndexPos && runtimeType == other.runtimeType && idxPath.length == other.idxPath.length && idxPath.toString() == other.idxPath.toString();

  @override
  int get hashCode => idxPath.hashCode;

  int get length => idxPath.length;

  bool get isRoot => idxPath.isEmpty;

  int get last => idxPath.last;

  _IndexPos append(int idx) => _IndexPos([...idxPath, idx]);

  _IndexPos replaceLast(int idx) => _IndexPos(idxPath.sublist(0, idxPath.length - 1)).append(idx);

  @override
  String toString() {
    return 'IndexPos: $idxPath';
  }
}
