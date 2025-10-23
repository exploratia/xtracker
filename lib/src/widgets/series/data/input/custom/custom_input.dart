import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/dialogs.dart';
import '../../../../../util/formatter/decimal_input_formatter.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../../controls/text/overflow_text.dart';
import '../input_header.dart';
import '../input_result.dart';

class CustomInput extends StatefulWidget {
  const CustomInput({
    super.key,
    this.customValue,
    required this.seriesDef,
  });

  final SeriesDef seriesDef;
  final CustomValue? customValue;

  static Future<InputResult<CustomValue>?> showInputDlg(BuildContext context, SeriesDef seriesDef, {CustomValue? customValue}) async {
    return await showDialog<InputResult<CustomValue>>(
      context: context,
      builder: (_) => CustomInput(
        seriesDef: seriesDef,
        customValue: customValue,
      ),
    );
  }

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, _SeriesItemData> _seriesItemsData = {};

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  late final String _uuid;
  DateTime _dateTime = DateTime.now();

  @override
  initState() {
    CustomValue? source = widget.customValue;
    _uuid = source?.uuid ?? const Uuid().v4();
    _dateTime = source?.dateTime ?? DateTime.now();

    for (var seriesItem in widget.seriesDef.seriesItems) {
      var seriesItemData = _SeriesItemData(seriesItem);
      seriesItemData.textEditingController.addListener(_validate);
      _seriesItemsData[seriesItem.siid] = seriesItemData;
    }

    if (source != null) {
      _isValid = true;
      _autoValidate = true;
      for (var valueEntry in source.values.entries) {
        var siid = valueEntry.key;
        var seriesItemData = _seriesItemsData[siid];
        if (seriesItemData != null) {
          seriesItemData.textEditingController.text = valueEntry.value.toString();
        }
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    for (var e in _seriesItemsData.values) {
      e.dispose();
    }
    super.dispose();
  }

  void _setDateTime(DateTime value) {
    setState(() {
      _dateTime = value;
    });
  }

  void _validate() {
    if (!_autoValidate) return;
    bool valid = _formKey.currentState?.validate() ?? false;
    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  void _saveHandler() async {
    bool insert = widget.customValue == null;
    setState(() {
      _autoValidate = true;
    });
    _validate();
    if (!_isValid) return;
    Map<String, double> values = {};
    for (var seriesItemData in _seriesItemsData.values) {
      final normalized = seriesItemData.textEditingController.text.replaceAll(',', '.');
      var val = double.tryParse(normalized);
      if (val != null) {
        values[seriesItemData.seriesItem.siid] = val;
      }
    }
    var val = CustomValue(_uuid, _dateTime, values);
    // First dismiss keyboard to trigger series view rebuild (-> series view animation)
    // and after a small delay pop the dialog with the return value - which then triggers the current value animation
    Dialogs.dismissKeyboard(context);
    await Future.delayed(const Duration(milliseconds: 300), () {});
    if (mounted) {
      Navigator.pop(context, InputResult(val, insert ? InputResultAction.insert : InputResultAction.update));
    }
  }

  void _deleteHandler(CustomValue customValue) async {
    bool? res = await Dialogs.simpleYesNoDialog(
      LocaleKeys.seriesValue_query_deleteValue.tr(),
      context,
      title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
    );
    if (res == true && mounted) {
      Navigator.pop(context, InputResult(customValue, InputResultAction.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var iconSize = ThemeUtils.iconSizeScaled;

    var edit = Form(
      key: _formKey,
      autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: ThemeUtils.verticalSpacing,
        children: [
          InputHeader(dateTime: _dateTime, seriesDef: widget.seriesDef, setDateTime: _setDateTime),
          const Divider(height: 1),
          ...widget.seriesDef.seriesItems.map((seriesItem) {
            var seriesItemData = _seriesItemsData[seriesItem.siid]!;
            return TextFormField(
              autofocus: seriesItem.siid == widget.seriesDef.seriesItems.first.siid,
              controller: seriesItemData.textEditingController,
              decoration: InputDecoration(
                labelText: seriesItemData.title,
                // hintText: "hint text",
              ),
              // Only numbers can be entered:
              inputFormatters: <TextInputFormatter>[DecimalInputFormatter()],
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null; // no value is allowed
                  // return LocaleKeys.commons_validator_emptyValue.tr();
                }
                final normalized = value.replaceAll(',', '.');
                var val = double.tryParse(normalized);
                if (val == null) {
                  return LocaleKeys.commons_validator_emptyValue.tr();
                }

                return null;
              },
            );
          }),
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
            widget.customValue == null ? Icon(Icons.add_outlined, size: iconSize) : Icon(Icons.edit_outlined, size: iconSize),
            OverflowText(widget.seriesDef.name),
            if (widget.customValue != null)
              IconButton(
                tooltip: LocaleKeys.seriesValue_action_deleteValue_tooltip.tr(),
                onPressed: () => _deleteHandler(widget.customValue!),
                color: themeData.colorScheme.secondary,
                iconSize: iconSize,
                icon: const Icon(Icons.delete_outlined),
              ),
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

class _SeriesItemData {
  final SeriesItem seriesItem;
  late final String title;
  late final String unit;
  late final TextEditingController textEditingController;

  _SeriesItemData(this.seriesItem) {
    title = seriesItem.name;
    unit = seriesItem.unit ?? '';
    textEditingController = TextEditingController();
  }

  void dispose() {
    textEditingController.dispose();
  }
}
