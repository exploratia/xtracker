import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/media_query_utils.dart';
import '../input_result.dart';
import '../simple_dialog_input.dart';

class DailyCheckInput extends StatefulWidget {
  const DailyCheckInput({super.key, this.dailyCheckValue, required this.seriesDef});

  final SeriesDef seriesDef;
  final DailyCheckValue? dailyCheckValue;

  static Future<InputResult<DailyCheckValue>?> showInputDlg(BuildContext context, SeriesDef seriesDef, {DailyCheckValue? dailyCheckValue}) async {
    return await showDialog<InputResult<DailyCheckValue>>(
      context: context,
      builder: (ctx) => DailyCheckInput(
        seriesDef: seriesDef,
        dailyCheckValue: dailyCheckValue,
      ),
    );
  }

  @override
  State<DailyCheckInput> createState() => _DailyCheckInputState();
}

class _DailyCheckInputState extends State<DailyCheckInput> {
  bool _isValid = true;

  late final String _uuid;
  late DateTime _dateTime;

  @override
  initState() {
    var source = widget.dailyCheckValue;
    _uuid = source?.uuid ?? const Uuid().v4();
    _dateTime = source?.dateTime ?? DateTime.now();

    super.initState();
  }

  void _setDateTime(DateTime value) {
    setState(() {
      _dateTime = value;
    });
  }

  void _toggleChecked() {
    setState(() {
      _isValid = !_isValid;
    });
  }

  void _saveHandler() {
    if (!_isValid) {
      // not valid means delete
      if (widget.dailyCheckValue != null) {
        _deleteHandler();
      } else {
        Navigator.pop(context, null);
      }
      return;
    }
    bool insert = widget.dailyCheckValue == null;
    var val = DailyCheckValue(_uuid, _dateTime);
    Navigator.pop(context, InputResult(val, insert ? InputResultAction.insert : InputResultAction.update));
  }

  void _deleteHandler() {
    if (widget.dailyCheckValue != null && mounted) {
      Navigator.pop(context, InputResult(widget.dailyCheckValue!, InputResultAction.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    var edit = IconButton(
      tooltip: LocaleKeys.seriesValue_dailyCheck_btn_toggleCheck_tooltip.tr(),
      iconSize: 40 * MediaQueryUtils.textScaleFactor,
      icon: Icon(_isValid ? Icons.check_box_outlined : Icons.check_box_outline_blank),
      onPressed: _toggleChecked,
    );

    return SimpleDialogInput(
      isEdit: widget.dailyCheckValue != null,
      isValid: _isValid,
      seriesDef: widget.seriesDef,
      dateTime: _dateTime,
      setDateTime: _setDateTime,
      saveHandler: _saveHandler,
      deleteHandler: _deleteHandler,
      child: edit,
    );
  }
}
