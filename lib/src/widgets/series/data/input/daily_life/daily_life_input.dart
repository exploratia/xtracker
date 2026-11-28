import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../model/series/tags/tag_resolver.dart';
import '../../../../controls/tag/tag_selector.dart';
import '../input_result.dart';
import '../simple_dialog_input.dart';

class DailyLifeInput extends StatefulWidget {
  const DailyLifeInput({super.key, this.dailyLifeValue, required this.seriesDef, required this.inputMode});

  final SeriesDef seriesDef;
  final DailyLifeValue? dailyLifeValue;
  final SeriesDataInputMode inputMode;

  static Future<InputResult<DailyLifeValue>?> showInputDlg(
    BuildContext context,
    SeriesDef seriesDef, {
    DailyLifeValue? dailyLifeValue,
    required SeriesDataInputMode inputMode,
  }) async {
    return await showDialog<InputResult<DailyLifeValue>>(
      context: context,
      builder: (ctx) => DailyLifeInput(
        seriesDef: seriesDef,
        dailyLifeValue: dailyLifeValue,
        inputMode: inputMode,
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
  String? _tagUuid;
  late final TagResolver _tagResolver;

  @override
  initState() {
    var source = widget.dailyLifeValue;
    _uuid = source?.uuid ?? const Uuid().v4();
    _dateTime = source?.dateTime ?? DateTime.now();
    _tagUuid = source?.tagId;

    if (source != null) {
      _isValid = true;
    }

    _tagResolver = TagResolver(widget.seriesDef);

    super.initState();
  }

  void _setDateTime(DateTime value) {
    setState(() {
      _dateTime = value;
    });
  }

  void _setTagUuid(String value) {
    setState(() {
      _tagUuid = value;
      _isValid = _tagUuid != null;
    });
  }

  void _saveHandler() {
    if (!_isValid) {
      return;
    }
    bool insert = widget.inputMode == SeriesDataInputMode.create;
    var val = DailyLifeValue(_uuid, _dateTime, _tagUuid!);
    Navigator.pop(context, InputResult(val, insert ? InputResultAction.insert : InputResultAction.update));
  }

  void _deleteHandler() {
    if (widget.dailyLifeValue != null && widget.inputMode == SeriesDataInputMode.edit && mounted) {
      Navigator.pop(context, InputResult(widget.dailyLifeValue!, InputResultAction.delete));
    }
  }

  @override
  Widget build(BuildContext context) {
    var tagSelector = TagSelector(
      tagUuid: _tagUuid,
      tags: widget.seriesDef.dailyLifeTagsSettingsReadonly().tags,
      handleTagUuid: _setTagUuid,
      tagResolver: _tagResolver,
    );

    return SimpleDialogInput(
      isEdit: widget.inputMode == SeriesDataInputMode.edit,
      isValid: _isValid,
      seriesDef: widget.seriesDef,
      dateTime: _dateTime,
      setDateTime: _setDateTime,
      saveHandler: _saveHandler,
      deleteHandler: _deleteHandler,
      child: tagSelector,
    );
  }
}
