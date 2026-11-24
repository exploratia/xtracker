import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/media_query_utils.dart';
import '../input_result.dart';
import '../simple_dialog_input.dart';

class HabitInput extends StatefulWidget {
  const HabitInput({super.key, this.habitValue, required this.seriesDef, required this.inputMode});

  final SeriesDef seriesDef;
  final HabitValue? habitValue;
  final SeriesDataInputMode inputMode;

  static Future<InputResult<HabitValue>?> showInputDlg(
    BuildContext context,
    SeriesDef seriesDef, {
    HabitValue? habitValue,
    required SeriesDataInputMode inputMode,
  }) async {
    return await showDialog<InputResult<HabitValue>>(
      context: context,
      builder: (ctx) => HabitInput(
        seriesDef: seriesDef,
        habitValue: habitValue,
        inputMode: inputMode,
      ),
    );
  }

  @override
  State<HabitInput> createState() => _HabitInputState();
}

class _HabitInputState extends State<HabitInput> {
  bool _isValid = true;

  late final String _uuid;
  late DateTime _dateTime;

  @override
  initState() {
    var source = widget.habitValue;
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
      if (widget.habitValue != null && widget.inputMode == SeriesDataInputMode.edit) {
        _deleteHandler();
      } else {
        Navigator.pop(context, null);
      }
      return;
    }
    bool insert = widget.inputMode == SeriesDataInputMode.create;
    var val = HabitValue(_uuid, _dateTime);
    Navigator.pop(context, InputResult<HabitValue>(val, insert ? InputResultAction.insert : InputResultAction.update));
  }

  void _deleteHandler() {
    if (widget.habitValue != null && widget.inputMode == SeriesDataInputMode.edit && mounted) {
      Navigator.pop(context, InputResult<HabitValue>(widget.habitValue!, InputResultAction.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    var edit = IconButton(
      tooltip: LocaleKeys.seriesValue_habit_btn_toggleValue_tooltip.tr(),
      iconSize: 40 * MediaQueryUtils.textScaleFactor,
      icon: Icon(_isValid ? Icons.check_box_outlined : Icons.check_box_outline_blank),
      onPressed: _toggleChecked,
    );

    return SimpleDialogInput(
      isEdit: widget.inputMode == SeriesDataInputMode.edit,
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
