import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../model/series/view_type.dart';
import '../../../../providers/series_data_provider.dart';
import '../../../provider/data_provider_loader.dart';
import 'blood_pressure/series_data_blood_pressure_view.dart';

class SeriesDataView extends StatelessWidget {
  const SeriesDataView({super.key, required this.seriesDef, required this.viewType});

  final SeriesDef seriesDef;
  final ViewType viewType;

  @override
  Widget build(BuildContext context) {
    return DataProviderLoader(
      obtainDataProviderFuture: context.read<SeriesDataProvider>().fetchDataIfNotYetLoaded(seriesDef),
      child: _SeriesDataView(
        seriesDef: seriesDef,
        viewType: viewType,
      ),
    );
  }
}

class _SeriesDataView extends StatelessWidget {
  const _SeriesDataView({
    required this.seriesDef,
    required this.viewType,
  });

  final SeriesDef seriesDef;
  final ViewType viewType;

  @override
  Widget build(BuildContext context) {
    return switch (seriesDef.seriesType) {
      SeriesType.bloodPressure => SeriesDataBloodPressureView(seriesDef: seriesDef, viewType: viewType),
      SeriesType.dailyCheck => throw UnimplementedError(),
      SeriesType.monthly => throw UnimplementedError(),
      SeriesType.free => throw UnimplementedError(),
    };
  }
}
