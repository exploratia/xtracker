import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../model/series/attributes/attribute_resolver.dart';
import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../controls/attribute/attribute_selector.dart';
import '../input_result.dart';
import '../simple_dialog_input.dart';

class DailyLifeInput extends StatefulWidget {
  const DailyLifeInput({super.key, this.dailyLifeValue, required this.seriesDef});

  final SeriesDef seriesDef;
  final DailyLifeValue? dailyLifeValue;

  static Future<InputResult<DailyLifeValue>?> showInputDlg(BuildContext context, SeriesDef seriesDef, {DailyLifeValue? dailyLifeValue}) async {
    return await showDialog<InputResult<DailyLifeValue>>(
      context: context,
      builder: (ctx) => DailyLifeInput(
        seriesDef: seriesDef,
        dailyLifeValue: dailyLifeValue,
      ),
    );
  }

  @override
  State<DailyLifeInput> createState() => _DailyLifeInputState();
}

class _DailyLifeInputState extends State<DailyLifeInput> {
  bool _isValid = false;

  late final String _uuid;
  late DateTime _dateTime;
  String? _attributeUuid;
  late final AttributeResolver _attributeResolver;

  @override
  initState() {
    var source = widget.dailyLifeValue;
    _uuid = source?.uuid ?? const Uuid().v4();
    _dateTime = source?.dateTime ?? DateTime.now();
    _attributeUuid = source?.aid;

    if (source != null) {
      _isValid = true;
    }

    _attributeResolver = AttributeResolver(widget.seriesDef);

    super.initState();
  }

  void _setDateTime(DateTime value) {
    setState(() {
      _dateTime = value;
    });
  }

  void _setAttributeUuid(String value) {
    setState(() {
      _attributeUuid = value;
      _isValid = _attributeUuid != null;
    });
  }

  void _saveHandler() {
    if (!_isValid) {
      return;
    }
    bool insert = widget.dailyLifeValue == null;
    var val = DailyLifeValue(_uuid, _dateTime, _attributeUuid!);
    Navigator.pop(context, InputResult(val, insert ? InputResultAction.insert : InputResultAction.update));
  }

  void _deleteHandler() {
    if (widget.dailyLifeValue != null && mounted) {
      Navigator.pop(context, InputResult(widget.dailyLifeValue!, InputResultAction.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    var attributeSelector = AttributeSelector(
      attributeUuid: _attributeUuid,
      attributes: widget.seriesDef.dailyLifeAttributesSettingsReadonly().attributes,
      handleAttributeUuid: _setAttributeUuid,
      attributeResolver: _attributeResolver,
    );

    return SimpleDialogInput(
      isEdit: widget.dailyLifeValue != null,
      isValid: _isValid,
      seriesDef: widget.seriesDef,
      dateTime: _dateTime,
      setDateTime: _setDateTime,
      saveHandler: _saveHandler,
      deleteHandler: _deleteHandler,
      child: attributeSelector,
    );
  }
}
