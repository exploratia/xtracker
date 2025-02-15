import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../model/series/series_def.dart';
import '../../../providers/series_data_provider.dart';
import '../../layout/centered_message.dart';
import '../../provider/data_provider_loader.dart';

class SeriesDataView extends StatelessWidget {
  const SeriesDataView({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return DataProviderLoader(
      obtainDataProviderFuture: context.read<SeriesDataProvider>().fetchDataIfNotYetLoaded(seriesDef),
      child: _SeriesDataView(seriesDef: seriesDef),
    );
  }
}

class _SeriesDataView extends StatelessWidget {
  const _SeriesDataView({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    var seriesDataProvider = context.watch<SeriesDataProvider>();
    var bloodPressureSeriesData = seriesDataProvider.bloodPressureData(seriesDef);
    if (bloodPressureSeriesData == null || bloodPressureSeriesData.isEmpty()) {
      return CenteredMessage(
        message: IntrinsicHeight(
          child: Column(
            children: [
              Icon(seriesDef.iconData(), color: seriesDef.color, size: 40),
              const Text("no data..."),
            ],
          ),
        ),
      );
    }
    return Text("${seriesDef.name} ${bloodPressureSeriesData.seriesItems.length}");
  }
}
