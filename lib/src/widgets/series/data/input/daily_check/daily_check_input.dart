import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../generated/locale_keys.g.dart';
import '../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../model/series/series_type.dart';
import '../../../../../providers/series_data_provider.dart';
import '../../../../../util/dialogs.dart';
import '../../view/daily_check/daily_check_value_renderer.dart';
import '../input_header.dart';

class DailyCheckInput extends StatefulWidget {
  const DailyCheckInput({super.key, this.dailyCheckValue, required this.seriesDef});

  final SeriesDef seriesDef;
  final DailyCheckValue? dailyCheckValue;

  static Future<DailyCheckValue?> showInputDlg(BuildContext context, SeriesDef seriesDef, {DailyCheckValue? dailyCheckValue}) async {
    final themeData = Theme.of(context);

    deleteHandler() async {
      bool? res = await Dialogs.simpleYesNoDialog(
        LocaleKeys.series_data_input_dialog_msg_query_deleteValue.tr(),
        context,
        title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
      );
      if (res == true) {
        try {
          if (context.mounted) {
            await context.read<SeriesDataProvider>().deleteValue(seriesDef, dailyCheckValue, context);
            if (context.mounted) Navigator.pop(context, null);
          }
        } catch (err) {
          if (context.mounted) {
            Dialogs.simpleErrOkDialog('$err', context);
          }
        }
      }
    }

    return await showDialog<DailyCheckValue>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                if (dailyCheckValue != null) const Icon(Icons.edit_outlined),
                if (dailyCheckValue == null) const Icon(Icons.add_circle_outline),
                const SizedBox(width: 10),
                Text(SeriesType.displayNameOf(seriesDef.seriesType)),
              ],
            ),
            if (dailyCheckValue != null) IconButton(onPressed: deleteHandler, color: themeData.colorScheme.primary, icon: const Icon(Icons.delete_outlined)),
          ],
        ),
        content: DailyCheckInput(dailyCheckValue: dailyCheckValue, seriesDef: seriesDef),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, null);
            },
            child: Text(LocaleKeys.commons_dialog_btn_cancel.tr()),
          ),
        ],
      ),
    );
  }

  @override
  State<DailyCheckInput> createState() => _DailyCheckInputState();
}

class _DailyCheckInputState extends State<DailyCheckInput> {
  late DateTime _dateTime;

  @override
  initState() {
    _dateTime = widget.dailyCheckValue?.dateTime ?? DateTime.now();
    super.initState();
  }

  _setDateTime(DateTime value) {
    setState(() {
      _dateTime = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? headerValueWidget =
        (widget.dailyCheckValue != null) ? DailyCheckValueRenderer(dailyCheckValue: widget.dailyCheckValue!, seriesDef: widget.seriesDef) : null;
    var header = InputHeader(dateTime: _dateTime, valueWidget: headerValueWidget, seriesDef: widget.seriesDef, setDateTime: _setDateTime);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        header,
        const Divider(height: 1),
        const SizedBox(height: 3),
        IconButton(
          iconSize: 40,
          icon: const Icon(Icons.check_box_outlined),
          onPressed: () {
            DailyCheckValue val;
            if (widget.dailyCheckValue != null) {
              val = widget.dailyCheckValue!.cloneWith(_dateTime);
            } else {
              val = DailyCheckValue(const Uuid().v4(), _dateTime);
            }
            Navigator.pop(context, val);
          },
        ),
      ],
    );
  }
}
