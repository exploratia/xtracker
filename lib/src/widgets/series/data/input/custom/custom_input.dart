import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../model/series/seriesItem/series_item.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../model/series/tags/tag_resolver.dart';
import '../../../../../util/date_time_utils.dart';
import '../../../../../util/dialogs.dart';
import '../../../../../util/formatter/decimal_input_formatter.dart';
import '../../../../../util/number_utils.dart';
import '../../../../controls/tag/tag_selector.dart';
import '../fullscreen_input.dart';
import '../input_result.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    this.customValue,
    required this.seriesDef,
    required this.inputMode,
  });

  final SeriesDef seriesDef;
  final CustomValue? customValue;
  final SeriesDataInputMode inputMode;

  static Future<InputResult<CustomValue>?> showInputDlg(
    BuildContext context,
    SeriesDef seriesDef, {
    CustomValue? customValue,
    required SeriesDataInputMode inputMode,
  }) async {
    return await showDialog<InputResult<CustomValue>>(
      context: context,
      builder: (context) => CustomInput(
        seriesDef: seriesDef,
        customValue: customValue,
        inputMode: inputMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SeriesItemsInput<CustomValue>(
      seriesDef: seriesDef,
      val: customValue,
      inputMode: inputMode,
      resultBuilder: (uuid, dateTime, values, tagId, action) => InputResult(CustomValue(uuid, dateTime, values, tagId), action),
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
    required this.inputMode,
  });

  final SeriesDef seriesDef;
  final V? val;
  final InputResult<V> Function(String uuid, DateTime dateTime, Map<String, double> values, String? tagId, InputResultAction inputResultAction) resultBuilder;
  final bool monthly;
  final SeriesDataInputMode inputMode;

  @override
  State<SeriesItemsInput> createState() => _SeriesItemsInputState();
}

class _SeriesItemsInputState<V extends CustomValue> extends State<SeriesItemsInput<V>> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, _SeriesItemData> _seriesItemsData = {};

  // auto validate after first call of save
  bool _autoValidate = false;
  bool _isValid = false;

  late final String _uuid;
  DateTime _dateTime = DateTime.now();
  String? _tagUuid;
  late final TagResolver _tagResolver;

  @override
  initState() {
    V? source = widget.val;
    _uuid = source?.uuid ?? const Uuid().v4();
    _dateTime = source?.dateTime ?? DateTime.now();
    // "correct" month in monthly if no dateTime is given
    if (widget.monthly && source == null) {
      _dateTime = _dateTime.day < 15 ? DateTimeUtils.firstDayOfPreviousMonth(_dateTime) : DateTimeUtils.firstDayOfMonth(_dateTime);
    }
    _tagUuid = source?.tagId;

    for (var seriesItem in widget.seriesDef.seriesItems) {
      // skip calculated seriesItems for input
      if (seriesItem.isCalculated) continue;
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
          seriesItemData.textEditingController.text = NumberUtils.formatNumber(valueEntry.value);
        }
      }
    }

    _tagResolver = TagResolver(widget.seriesDef);

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

  void _setTagUuid(String? value) {
    setState(() {
      _tagUuid = value;
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
    bool insert = widget.inputMode == SeriesDataInputMode.create;
    setState(() {
      _autoValidate = true;
    });
    _validate();
    if (!_isValid) return;
    Map<String, double> values = {};
    for (var seriesItemData in _seriesItemsData.values) {
      var val = NumberUtils.tryParse(seriesItemData.textEditingController.text);
      if (val != null) {
        values[seriesItemData.seriesItem.siid] = val;
      }
    }
    var inputResult = widget.resultBuilder(_uuid, _dateTime, values, _tagUuid, insert ? InputResultAction.insert : InputResultAction.update);
    // First dismiss keyboard to trigger series view rebuild (-> series view animation)
    // and after a small delay pop the dialog with the return value - which then triggers the current value animation
    Dialogs.dismissKeyboard(context);
    await Future.delayed(const Duration(milliseconds: 300), () {});
    if (mounted) {
      Navigator.pop<InputResult<V>>(context, inputResult);
    }
  }

  void _deleteHandler() {
    if (widget.val != null && widget.inputMode == SeriesDataInputMode.edit && mounted) {
      var val = widget.val!;
      var delResult = widget.resultBuilder(val.uuid, val.dateTime, val.values, val.tagId, InputResultAction.delete);
      Navigator.pop<InputResult<V>>(context, delResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    var seriesDefTags = widget.seriesDef.customTagsSettingsReadonly().tags;
    List<Widget> formChildren = [
      ...widget.seriesDef.seriesItems.where((si) => !si.isCalculated).map(
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
              var dVal = NumberUtils.tryParse(value);
              if (dVal == null) {
                return LocaleKeys.commons_validator_emptyValue.tr();
              }

              return null;
            },
          );
        },
      ),
      // tags?
      if (seriesDefTags.isNotEmpty)
        TagSelector(
          tagUuid: _tagUuid,
          tags: seriesDefTags,
          tagResolver: _tagResolver,
          handleTagUuid: _setTagUuid,
          deleteTagUuid: (_tagUuid == null ? null : () => _setTagUuid(null)),
        ),
    ];

    return FullscreenInput(
      formKey: _formKey,
      formChildren: formChildren,
      autoValidate: _autoValidate,
      isEdit: widget.inputMode == SeriesDataInputMode.edit,
      seriesDef: widget.seriesDef,
      dateTime: _dateTime,
      setDateTime: _setDateTime,
      monthly: widget.monthly,
      saveHandler: _saveHandler,
      deleteHandler: _deleteHandler,
    );
  }
}

class _SeriesItemData {
  final SeriesItem seriesItem;
  late final TextEditingController textEditingController;

  _SeriesItemData(this.seriesItem) {
    textEditingController = TextEditingController();
  }

  void dispose() {
    textEditingController.dispose();
  }
}
