import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../model/series/series_def.dart';

class SeriesLatestValue extends StatelessWidget {
  const SeriesLatestValue({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Text(seriesDef.uuid);
  }
}
