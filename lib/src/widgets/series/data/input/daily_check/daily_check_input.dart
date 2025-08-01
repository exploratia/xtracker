import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../providers/series_data_provider.dart';
import '../../../../../util/dialogs.dart';
import '../../../../../util/logging/flutter_simple_logging.dart';
import '../../../../../util/theme_utils.dart';
import '../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../../controls/text/overflow_text.dart';
import '../input_header.dart';

class DailyCheckInput extends StatefulWidget {
  const DailyCheckInput({super.key, this.dailyCheckValue, required this.seriesDef});

  final SeriesDef seriesDef;
  final DailyCheckValue? dailyCheckValue;

  static Future<DailyCheckValue?> showInputDlg(BuildContext context, SeriesDef seriesDef, {DailyCheckValue? dailyCheckValue}) async {
    return await showDialog<DailyCheckValue>(
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
    var val = DailyCheckValue(_uuid, _dateTime);
    Navigator.pop(context, val);
  }

  void _deleteHandler() async {
    bool? res = await Dialogs.simpleYesNoDialog(
      LocaleKeys.seriesValue_query_deleteValue.tr(),
      context,
      title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
    );
    if (res == true) {
      try {
        if (mounted) {
          await context.read<SeriesDataProvider>().deleteValue(widget.seriesDef, widget.dailyCheckValue, context);
          if (mounted) Navigator.pop(context, null);
        }
      } catch (err) {
        SimpleLogging.w('Failed to delete daily check value.', error: err);
        if (mounted) {
          Dialogs.simpleErrOkDialog('$err', context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    var edit = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        InputHeader(dateTime: _dateTime, seriesDef: widget.seriesDef, setDateTime: _setDateTime),
        const Divider(height: 1),
        const SizedBox(height: 3),
        IconButton(
          tooltip: LocaleKeys.seriesValue_dailyCheck_btn_toggleCheck_tooltip.tr(),
          iconSize: 40,
          icon: Icon(_isValid ? Icons.check_box_outlined : Icons.check_box_outline_blank),
          onPressed: _toggleChecked,
        ),
      ],
    );

    return AlertDialog(
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ThemeUtils.seriesDataInputDlgMaxWidth),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.dailyCheckValue == null ? const Icon(Icons.add_outlined) : const Icon(Icons.edit_outlined),
            const SizedBox(width: 10),
            OverflowText(widget.seriesDef.name),
            // Text(SeriesType.displayNameOf(widget.seriesDef.seriesType)),
            if (widget.dailyCheckValue != null)
              IconButton(
                tooltip: LocaleKeys.seriesValue_action_deleteValue_tooltip.tr(),
                onPressed: _deleteHandler,
                color: themeData.colorScheme.secondary,
                icon: const Icon(Icons.delete_outlined),
              ),
          ],
        ),
      ),
      content: SingleChildScrollViewWithScrollbar(
        useScreenPadding: false,
        child: edit,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text(LocaleKeys.commons_dialog_btn_cancel.tr()),
        ),
        if (_isValid)
          TextButton(
            onPressed: _saveHandler,
            child: Text(LocaleKeys.commons_dialog_btn_okay.tr()),
          ),
        if (!_isValid && widget.dailyCheckValue != null)
          TextButton(
            onPressed: _deleteHandler,
            child: Text(LocaleKeys.commons_dialog_btn_delete.tr()),
          ),
      ],
    );
  }
}
