import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/date_time_utils.dart';
import '../../../../../util/dialogs.dart';
import '../../../../../util/formatter/decimal_input_formatter.dart';
import '../fullscreen_input.dart';
import '../input_result.dart';

class CustomInput extends StatelessWidget {
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
      builder: (context) => CustomInput(
        seriesDef: seriesDef,
        customValue: customValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SeriesItemsInput<CustomValue>(
      seriesDef: seriesDef,
      val: customValue,
      resultBuilder: (uuid, dateTime, values, action) => InputResult(CustomValue(uuid, dateTime, values), action),
    );
  }
}

class SeriesItemsInput<V extends CustomValue> extends StatefulWidget {
  const SeriesItemsInput({
    super.key,
    this.val,
    required this.seriesDef,
    required this.resultBuilder,
    this.monthly = false,
  });

  final SeriesDef seriesDef;
  final V? val;
  final InputResult<V> Function(String uuid, DateTime dateTime, Map<String, double> values, InputResultAction inputResultAction) resultBuilder;
  final bool monthly;

  @override
  State<SeriesItemsInput> createState() => _SeriesItemsInputState();
}

class _SeriesItemsInputState<V extends CustomValue> extends State<SeriesItemsInput<V>> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, SeriesItemData> _seriesItemsData = {};

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  late final String _uuid;
  DateTime _dateTime = DateTime.now();

  @override
  initState() {
    V? source = widget.val;
    _uuid = source?.uuid ?? const Uuid().v4();
    _dateTime = source?.dateTime ?? DateTime.now();
    // "correct" month in monthly if no dateTime is given
    if (widget.monthly && source == null) {
      _dateTime = _dateTime.day < 15 ? DateTimeUtils.firstDayOfPreviousMonth(_dateTime) : DateTimeUtils.firstDayOfMonth(_dateTime);
    }

    for (var seriesItem in widget.seriesDef.seriesItems) {
      var seriesItemData = SeriesItemData(seriesItem);
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
    bool insert = widget.val == null;
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
    var inputResult = widget.resultBuilder(_uuid, _dateTime, values, insert ? InputResultAction.insert : InputResultAction.update);
    // First dismiss keyboard to trigger series view rebuild (-> series view animation)
    // and after a small delay pop the dialog with the return value - which then triggers the current value animation
    Dialogs.dismissKeyboard(context);
    await Future.delayed(const Duration(milliseconds: 300), () {});
    if (mounted) {
      Navigator.pop<InputResult<V>>(context, inputResult);
    }
  }

  void _deleteHandler() {
    if (widget.val != null && mounted) {
      Navigator.pop(context, InputResult<V>(widget.val!, InputResultAction.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formChildren = [
      ...widget.seriesDef.seriesItems.map(
        (seriesItem) {
          var seriesItemData = _seriesItemsData[seriesItem.siid]!;
          return TextFormField(
            autofocus: seriesItem.siid == widget.seriesDef.seriesItems.first.siid,
            controller: seriesItemData.textEditingController,
            decoration: InputDecoration(
              labelText: seriesItem.name + seriesItem.unitInBrackets(emptyStringIfNullOrEmpty: true),
              prefixIcon: Icon(widget.seriesDef.iconData()),
              prefixIconColor: seriesItem.color,
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
              var dVal = double.tryParse(normalized);
              if (dVal == null) {
                return LocaleKeys.commons_validator_emptyValue.tr();
              }

              return null;
            },
          );
        },
      ),
    ];

    return FullscreenInput(
      formKey: _formKey,
      formChildren: formChildren,
      autoValidate: _autoValidate,
      isEdit: widget.val != null,
      seriesDef: widget.seriesDef,
      dateTime: _dateTime,
      setDateTime: _setDateTime,
      monthly: widget.monthly,
      saveHandler: _saveHandler,
      deleteHandler: _deleteHandler,
    );
  }
}

class SeriesItemData {
  final SeriesItem seriesItem;
  late final TextEditingController textEditingController;

  SeriesItemData(this.seriesItem) {
    textEditingController = TextEditingController();
  }

  void dispose() {
    textEditingController.dispose();
  }
}
