import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/series/series_def.dart';

class AddFirstSeries extends StatelessWidget {
  const AddFirstSeries({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeData = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            iconSize: 40,
            color: themeData.colorScheme.primary,
            onPressed: () async {
              /*SeriesDef? s=*/ await SeriesDef.addNewSeries(context);
            },
            icon: const Icon(Icons.add_chart_outlined)),
        Center(child: Text(t.seriesAddFirstSeries)),
      ],
    );
  }
}
