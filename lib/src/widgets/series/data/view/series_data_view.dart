import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../model/series/series_type.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../providers/series_data_provider.dart';
import '../../../provider/data_provider_loader.dart';
import 'blood_pressure/series_data_blood_pressure_view.dart';

class SeriesDataView extends StatelessWidget {
  const SeriesDataView({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    return DataProviderLoader(
      obtainDataProviderFuture: context.read<SeriesDataProvider>().fetchDataIfNotYetLoaded(seriesViewMetaData.seriesDef),
      child: _SeriesDataView(seriesViewMetaData: seriesViewMetaData),
    );
  }
}

class _SeriesDataView extends StatelessWidget {
  const _SeriesDataView({required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    return switch (seriesViewMetaData.seriesDef.seriesType) {
      SeriesType.bloodPressure => SeriesDataBloodPressureView(seriesViewMetaData: seriesViewMetaData),
      SeriesType.dailyCheck => throw UnimplementedError(),
      SeriesType.monthly => throw UnimplementedError(),
      SeriesType.free => throw UnimplementedError(),
    };
  }
}
