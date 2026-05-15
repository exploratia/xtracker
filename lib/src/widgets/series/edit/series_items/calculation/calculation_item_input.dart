import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_container.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_input_type.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_item.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_item_numeric.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_item_series_value.dart';
import '../../../../../model/series/seriesItem/calculated/calculation_operator.dart';
import '../../../../../model/series/seriesItem/series_item.dart';
import '../../../../../util/formatter/decimal_input_formatter.dart';
import '../../../../../util/number_utils.dart';
import '../../../../../util/table_utils.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/form/validation_field.dart';
import '../../../../controls/layout/drop_down_menu_item_child.dart';
import '../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../../controls/text/overflow_text.dart';
import '../../../../controls/tooltip/lazy_tooltip.dart';
import 'calculation_series_item_renderer.dart';

class CalculationItemInput extends StatefulWidget {
  const CalculationItemInput({
    super.key,
    this.calculationItem,
    required this.availableSeriesItems,
  });

  final CalculationItem? calculationItem;
  final List<SeriesItem> availableSeriesItems;

  ///
  /// -[existingSeriesItems] readonly! just to get information
  static Future<CalculationItem?> showInputDlg(
    BuildContext context, {
    CalculationItem? calculationItem,
    required List<SeriesItem> existingSeriesItems,
  }) async {
    return await showDialog<CalculationItem>(
      context: context,
      builder: (_) => CalculationItemInput(
        calculationItem: calculationItem,
        availableSeriesItems: existingSeriesItems,
      ),
    );
  }

  @override
  State<CalculationItemInput> createState() => _CalculationItemInputState();
}

class _CalculationItemInputState extends State<CalculationItemInput> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  late CalculationOperator _operator;
  late CalculationInputType _inputType;
  late String? _sourceSiid;
  late bool _usePreviousInput;

  @override
  initState() {
    var source = widget.calculationItem;

    _operator = source?.operator ?? CalculationOperator.add;
    _inputType = source?.inputType ?? CalculationInputType.numeric;

    _valueController.addListener(_validate);
    if (source is CalculationItemNumeric) {
      _valueController.text = NumberUtils.formatNumber(source.value);
    }

    if (source is CalculationItemSeriesValue) {
      _sourceSiid = source.calculationContainer.sourceSiid;
      _usePreviousInput = source.calculationContainer.usePreviousInput;
    } else {
      _sourceSiid = null;
      _usePreviousInput = false;
    }

    if (source != null) {
      _isValid = true;
      _autoValidate = true;
    }

    super.initState();
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _setOperator(CalculationOperator? value) {
    if (value == null) return;
    setState(() {
      _operator = value;
    });
  }

  void _setInputType(CalculationInputType? value) {
    if (value == null) return;
    setState(() {
      _inputType = value;
    });
  }

  void _setSourceSiid(String value) {
    setState(() {
      _sourceSiid = value;
    });
  }

  void _setUsePreviousInput(bool value) {
    setState(() {
      _usePreviousInput = value;
    });
  }

  void _validate() {
    if (!_autoValidate) return;
    bool valid;

    switch (_inputType) {
      case CalculationInputType.numeric:
        valid = _formKey.currentState?.validate() ?? false;
      case CalculationInputType.seriesValue:
        valid = _sourceSiid != null;
    }

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

    var source = widget.calculationItem;

    CalculationItem val;

    switch (_inputType) {
      case CalculationInputType.numeric:
        val = CalculationItemNumeric(
          value: NumberUtils.tryParse(_valueController.text) ?? 0,
          operator: _operator,
        );
      case CalculationInputType.seriesValue:
        List<CalculationItem> items = [];
        if (source is CalculationItemSeriesValue) items = source.calculationContainer.calculationItems;
        val = CalculationItemSeriesValue(
          calculationContainer: CalculationContainer(sourceSiid: _sourceSiid!, calculationItems: items, usePreviousInput: _usePreviousInput),
          operator: _operator,
        );
    }

    Navigator.pop(context, val);
  }

  @override
  Widget build(BuildContext context) {
    var iconSize = ThemeUtils.iconSizeScaled;

    var edit = Form(
      key: _formKey,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: ThemeUtils.verticalSpacing,
        children: [
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            // https://api.flutter.dev/flutter/widgets/Table-class.html
            columnWidths: <int, TableColumnWidth>{
              // 0: FixedColumnWidth(96 * MediaQueryUtils.textScaleFactor),
              0: const IntrinsicColumnWidth(),
              1: const IntrinsicColumnWidth(),
              // 1: FlexColumnWidth(),
            },
            // border: TableBorder.symmetric(
            //   inside: const BorderSide(width: 1, color: Colors.black12),
            // ),
            children: [
              TableUtils.tableRow([
                Text(LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_calculationItemSettingsDlg_label_operator.tr()),
                DropdownButton<CalculationOperator>(
                  key: const Key('operatorSelect'),
                  borderRadius: ThemeUtils.cardBorderRadius,
                  value: _operator,
                  onChanged: (value) => _setOperator(value),
                  items: CalculationOperator.values.map((o) {
                    return DropdownMenuItem<CalculationOperator>(
                      key: Key('operatorSelect_$o'),
                      value: o,
                      child: DropDownMenuItemChild(
                        selected: _operator == o,
                        child: Text('${o.displayName}${CalculationOperator.toBracketDisplayString(o)}'),
                      ),
                    );
                  }).toList(),
                ),
              ]),
              TableUtils.tableRow([
                Text(LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_calculationItemSettingsDlg_label_inputType.tr()),
                DropdownButton<CalculationInputType>(
                  key: const Key('inputTypeSelect'),
                  borderRadius: ThemeUtils.cardBorderRadius,
                  value: _inputType,
                  onChanged: (value) => _setInputType(value),
                  items: CalculationInputType.values.map((i) {
                    var text = Text(CalculationInputType.toDisplayString(i));
                    return DropdownMenuItem<CalculationInputType>(
                      key: Key('inputTypeSelect_$i'),
                      value: i,
                      child: DropDownMenuItemChild(selected: i == _inputType, child: text),
                    );
                  }).toList(),
                ),
              ]),
            ],
          ),
          const Divider(),

          // depending on input type
          if (_inputType == CalculationInputType.numeric)
            TextFormField(
              autofocus: true,
              controller: _valueController,
              decoration: InputDecoration(
                labelText: LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_calculationItemSettingsDlg_label_value.tr(),
              ),
              // Only numbers can be entered:
              inputFormatters: <TextInputFormatter>[DecimalInputFormatter()],
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleKeys.commons_validator_emptyValue.tr();
                }
                var dVal = NumberUtils.tryParse(value);
                if (dVal == null) {
                  return LocaleKeys.commons_validator_emptyValue.tr();
                }

                return null;
              },
            ),
          if (_inputType == CalculationInputType.seriesValue) ...[
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
                onChanged: (value) => _setUsePreviousInput(value),
              ),
            ),
          ],
        ],
      ),
    );

    return AlertDialog(
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ThemeUtils.seriesDataInputDlgMaxWidth),
        child: Row(
          spacing: ThemeUtils.horizontalSpacing,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.calculationItem == null ? Icon(Icons.add_outlined, size: iconSize) : Icon(Icons.edit_outlined, size: iconSize),
            OverflowText(LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_calculationItemSettingsDlg_title.tr()),
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
