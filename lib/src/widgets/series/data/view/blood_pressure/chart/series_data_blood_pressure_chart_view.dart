import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';

class SeriesDataBloodPressureChartView extends StatelessWidget {
  const SeriesDataBloodPressureChartView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesViewMetaData seriesViewMetaData;
  final SeriesData<BloodPressureValue> seriesData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text("TODO Chart for ${seriesViewMetaData.seriesDef.name} ${seriesData.seriesItems.length}"),
      ],
    );
  }
}
