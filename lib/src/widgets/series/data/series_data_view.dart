import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SeriesDataView extends StatelessWidget {
  const SeriesDataView({super.key, required this.seriesUuid});

  final String seriesUuid;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [Text(seriesUuid)],
    );
  }
}
