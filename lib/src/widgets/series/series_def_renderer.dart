import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../model/series/series_def.dart';
import '../../providers/series_provider.dart';
import '../../util/dialogs.dart';
import '../card/glowing_border_container.dart';
import '../select/icon_map.dart';

class SeriesDefRenderer extends StatelessWidget {
  const SeriesDefRenderer({
    super.key,
    required this.seriesDef,
    this.editMode = false,
  });

  final SeriesDef seriesDef;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    deleteHandler() async {
      bool? res = await Dialogs.simpleYesNoDialog(
          t.seriesDialogMsgQueryDeleteSeries(seriesDef.name), context,
          title: t.commonsDialogTitleAreYouSure);
      if (res == true) {
        try {
          if (context.mounted) {
            await context.read<SeriesProvider>().remove(seriesDef);
          }
        } catch (err) {
          if (context.mounted) {
            Dialogs.simpleErrOkDialog('$err', context);
          }
        }
      }
    }

    return GlowingBorderContainer(
        glowColor: seriesDef.color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconMap.icon(seriesDef.iconName),
                ),
                Expanded(child: Text(seriesDef.name)),
                if (editMode)
                  SizedBox(
                    height: 40,
                    child: VerticalDivider(
                      thickness: 1,
                      color: seriesDef.color,
                    ),
                  ),
                if (editMode)
                  IconButton(
                      onPressed: deleteHandler,
                      icon: const Icon(Icons.close_outlined)),
                if (editMode)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.drag_handle_outlined),
                  ),
              ],
            ),
          ],
        ));
  }
}
