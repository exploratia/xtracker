import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../model/series/series_def.dart';
import '../../../providers/series_provider.dart';
import '../../../util/dialogs.dart';

class SeriesManagementActions extends StatelessWidget {
  const SeriesManagementActions({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 40,
          child: VerticalDivider(
            thickness: 1,
            color: seriesDef.color,
          ),
        ),
        _DeleteSeriesBtn(seriesDef: seriesDef),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.drag_handle_outlined),
        ),
      ],
    );
  }
}

class _DeleteSeriesBtn extends StatelessWidget {
  const _DeleteSeriesBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    deleteHandler() async {
      bool? res = await Dialogs.simpleYesNoDialog(
        t.seriesDialogMsgQueryDeleteSeries(seriesDef.name),
        context,
        title: t.commonsDialogTitleAreYouSure,
      );
      if (res == true) {
        try {
          if (context.mounted) {
            await context.read<SeriesProvider>().delete(seriesDef);
          }
        } catch (err) {
          if (context.mounted) {
            Dialogs.simpleErrOkDialog('$err', context);
          }
        }
      }
    }

    return IconButton(onPressed: deleteHandler, icon: const Icon(Icons.close_outlined));
  }
}
