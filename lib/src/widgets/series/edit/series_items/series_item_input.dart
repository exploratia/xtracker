import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/seriesItem/calculated/calculation_container.dart';
import '../../../../model/series/seriesItem/series_item.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../model/series/settings/daily_life/daily_life_attribute.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/form/validation_field.dart';
import '../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../controls/select/color_picker.dart';
import '../../../controls/text/overflow_text.dart';
import 'calculation/series_item_calculation.dart';

class SeriesItemInput extends StatefulWidget {
  const SeriesItemInput({
    super.key,
    this.seriesItem,
    required this.seriesDef,
    required this.isCalculated,
  });

  final SeriesItem? seriesItem;
  final bool isCalculated;
  final SeriesDef seriesDef;

  ///
  /// -[existingSeriesItems] readonly! just to get information
  static Future<SeriesItem?> showInputDlg(
    BuildContext context, {
    SeriesItem? seriesItem,
    bool? createCalculatedItem,
    required SeriesDef seriesDef,
  }) async {
    return await showDialog<SeriesItem>(
      context: context,
      builder: (_) => SeriesItemInput(
        seriesItem: seriesItem,
        isCalculated: seriesItem != null ? seriesItem.isCalculated : (createCalculatedItem ?? false),
        seriesDef: seriesDef,
      ),
    );
  }

  @override
  State<SeriesItemInput> createState() => _SeriesItemInputState();
}

class _SeriesItemInputState extends State<SeriesItemInput> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  late final String _siid;
  late Color _color;

  late final bool _isCalculated;

  CalculationContainer? _calculationContainer;

  @override
  initState() {
    var source = widget.seriesItem;
    _siid = source?.siid ?? DailyLifeAttribute.generateUniqueAttributeId();
    _color = source?.color ?? widget.seriesDef.color;
    _isCalculated = widget.isCalculated;

    _nameController.addListener(_validate);
    _unitController.addListener(_validate);
    if (source != null) {
      _isValid = true;
      _autoValidate = true;
      _nameController.text = source.name.toString();
      _unitController.text = source.unit.toString();

      _calculationContainer = source.calculationContainer;
    }

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _setColor(Color value) {
    setState(() {
      _color = value;
    });
  }

  void _setCalculationContainer(CalculationContainer value) {
    setState(() {
      _calculationContainer = value;
    });
  }

  void _validate() {
    if (!_autoValidate) return;
    bool valid = _formKey.currentState?.validate() ?? false;

    if (valid && _isCalculated) valid = _calculationContainer != null;

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

    var source = widget.seriesItem;

    // defaults for ext settings
    var hideInTable = false;
    var hideInChart = false;
    int? tableColumnWidth;
    // for monthly series set usDelta true as default
    var useDeltaInChart = widget.seriesDef.seriesType == SeriesType.monthly;
    // source available?
    if (source != null) {
      hideInTable = source.hideInTable;
      hideInChart = source.hideInTable;
      tableColumnWidth = source.tableColumnWidth;
      useDeltaInChart = source.useDeltaInChart;
    }

    SeriesItem val = SeriesItem(
      _siid,
      _nameController.text,
      _unitController.text,
      _color,
      hideInTable,
      hideInChart,
      tableColumnWidth,
      useDeltaInChart,
      _calculationContainer,
    );

    Navigator.pop(context, val);
  }

  @override
  Widget build(BuildContext context) {
    var iconSize = ThemeUtils.iconSizeScaled;

    SeriesItemCalculation? calculationInput;
    if (_isCalculated) {
      calculationInput = SeriesItemCalculation(
        calculationContainer: _calculationContainer,
        availableSeriesItems: widget.seriesDef.seriesItems.where((i) => !i.isCalculated).toList(),
        setCalculationContainer: _setCalculationContainer,
      );
    }

    var edit = Form(
      key: _formKey,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: ThemeUtils.verticalSpacing,
        children: [
          TextFormField(
            autofocus: true,
            controller: _nameController,
            decoration: InputDecoration(
              labelText: LocaleKeys.seriesEdit_common_label_seriesItemName.tr(),
              // hintText: "hint text",
            ),
            textInputAction: TextInputAction.next,
            // unicode is possible - e.g. from https://www.compart.com/de/unicode/block/U+1F600
            validator: (value) {
              if (value == null || value.isEmpty) {
                return LocaleKeys.commons_validator_emptyValue.tr();
              }
              return null;
            },
          ),
          TextFormField(
            autofocus: true,
            controller: _unitController,
            decoration: InputDecoration(
              labelText: LocaleKeys.seriesEdit_common_label_seriesItemUnit.tr(),
              // hintText: "hint text",
            ),
            textInputAction: TextInputAction.next,
            // unicode is possible - e.g. from https://www.compart.com/de/unicode/block/U+1F600
            validator: (value) {
              // null/empty is allowed
              return null;
            },
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: ThemeUtils.horizontalSpacing,
              children: [
                Text(LocaleKeys.seriesEdit_common_label_seriesColor.tr()),
                ColorPicker(
                  color: _color,
                  colorSelected: _setColor,
                ),
              ],
            ),
          ),
          if (calculationInput != null) ...[
            const Divider(),
            calculationInput,
            ValidationField(
              validatorCondition: () => _calculationContainer != null,
              errorMessage: LocaleKeys.seriesEdit_seriesSettings_seriesItems_calculation_validation_emptyCalculation.tr(),
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
            widget.seriesItem == null ? Icon(Icons.add_outlined, size: iconSize) : Icon(Icons.edit_outlined, size: iconSize),
            if (_isCalculated) Icon(Icons.link_outlined, size: iconSize),
            OverflowText(LocaleKeys.seriesEdit_seriesSettings_seriesItems_dlg_title.tr()),
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
