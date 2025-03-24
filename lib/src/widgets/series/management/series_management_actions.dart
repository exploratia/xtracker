import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
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
        Container(color: seriesDef.color, width: 2, height: 40),
        _DeleteSeriesBtn(seriesDef: seriesDef),
        if (!kIsWeb)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.drag_handle_outlined),
          ),
        if (kIsWeb) const SizedBox(width: 16),
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
    deleteHandler() async {
      bool? res = await Dialogs.simpleYesNoDialog(
        LocaleKeys.series_dialog_msg_query_deleteSeries.tr(args: [seriesDef.name]),
        context,
        title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
      );
      if (res == true) {
        try {
          if (context.mounted) {
            await context.read<SeriesProvider>().delete(seriesDef, context);
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
