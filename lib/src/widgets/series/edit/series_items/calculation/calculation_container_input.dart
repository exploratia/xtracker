import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_container.dart';
import '../../../../../model/series/seriesItem/series_item.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/form/validation_field.dart';
import '../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../../controls/text/overflow_text.dart';
import '../../../../controls/tooltip/lazy_tooltip.dart';
import 'calculation_series_item_renderer.dart';

class CalculationContainerInput extends StatefulWidget {
  const CalculationContainerInput({
    super.key,
    this.calculationContainer,
    required this.availableSeriesItems,
  });

  final CalculationContainer? calculationContainer;
  final List<SeriesItem> availableSeriesItems;

  ///
  /// -[existingSeriesItems] readonly! just to get information
  static Future<CalculationContainer?> showInputDlg(
    BuildContext context, {
    CalculationContainer? calculationContainer,
    required List<SeriesItem> existingSeriesItems,
  }) async {
    return await showDialog<CalculationContainer>(
      context: context,
      builder: (_) => CalculationContainerInput(
        calculationContainer: calculationContainer,
        availableSeriesItems: existingSeriesItems,
      ),
    );
  }

  @override
  State<CalculationContainerInput> createState() => _CalculationContainerInputState();
}

class _CalculationContainerInputState extends State<CalculationContainerInput> {
  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  late String? _sourceSiid;
  late bool _usePreviousInput;

  @override
  initState() {
    var source = widget.calculationContainer;
    _sourceSiid = source?.sourceSiid;
    _usePreviousInput = source?.usePreviousInput ?? false;

    if (source != null) {
      _isValid = true;
      _autoValidate = true;
    }

    super.initState();
  }

  void _setSourceSiid(String value) {
    setState(() {
      _sourceSiid = value;
    });
  }

  void _validate() {
    if (!_autoValidate) return;

    bool valid = _sourceSiid != null;

    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  void _saveHandler() {
    setState(() {
      _autoValidate = true;
    });
    _validate();
    if (!_isValid) return;

    var source = widget.calculationContainer;

    CalculationContainer val = CalculationContainer(
      sourceSiid: _sourceSiid!,
      usePreviousInput: _usePreviousInput,
      calculationItems: source != null ? source.calculationItems : [],
    );

    Navigator.pop(context, val);
  }

  @override
  Widget build(BuildContext context) {
    var iconSize = ThemeUtils.iconSizeScaled;

    var edit = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: ThemeUtils.verticalSpacing,
      children: [
        Center(
          child: PopupMenuButton(
            borderRadius: ThemeUtils.borderRadiusCircular,
            icon: _sourceSiid == null ? const Icon(Icons.list) : null,
            tooltip: LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_btn_selectSeriesItem_tooltip.tr(),
            itemBuilder: (context) => widget.availableSeriesItems
                .map(
                  (e) => PopupMenuItem(
                    /* Flutter Bug? if right >= 10 a huge wider padding is used. Seems not to work always. If only Text-Widgets are uses as child it has no effect. */
                    padding: const EdgeInsets.only(right: 9, left: 9, bottom: 0),
                    onTap: () => _setSourceSiid(e.siid),
                    child: CalculationSeriesItemRenderer(seriesItem: e),
                  ),
                )
                .toList(),
            child: _sourceSiid != null
                ? Padding(
                    padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
                    child: CalculationSeriesItemRenderer(
                      seriesItem: widget.availableSeriesItems.firstWhere((element) => element.siid == _sourceSiid),
                    ),
                  )
                : null,
          ),
        ),
        ValidationField(
          validatorCondition: () => !_autoValidate || _sourceSiid != null,
          errorMessage: LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_validation_emptyParameter.tr(),
        ),
        LazyTooltip(
          tooltipBuilder: (BuildContext c) => Text(LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_switch_usePreviousValue_tooltip.tr()),
          child: SwitchListTile(
            secondary: const Icon(Icons.arrow_back_outlined),
            title: Text(LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_switch_usePreviousValue_label.tr()),
            value: _usePreviousInput,
            onChanged: (value) {
              setState(() {
                _usePreviousInput = value;
              });
            },
          ),
        ),
      ],
    );

    return AlertDialog(
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ThemeUtils.seriesDataInputDlgMaxWidth),
        child: Row(
          spacing: ThemeUtils.horizontalSpacing,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.calculationContainer == null ? Icon(Icons.add_outlined, size: iconSize) : Icon(Icons.edit_outlined, size: iconSize),
            OverflowText(LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_parameterSettingsDlg_title.tr()),
          ],
        ),
      ),
      content: SingleChildScrollViewWithScrollbar(
        child: edit,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text(LocaleKeys.commons_dialog_btn_cancel.tr()),
        ),
        TextButton(
          onPressed: _saveHandler,
          child: Text(LocaleKeys.commons_dialog_btn_okay.tr()),
        ),
      ],
    );
  }
}
