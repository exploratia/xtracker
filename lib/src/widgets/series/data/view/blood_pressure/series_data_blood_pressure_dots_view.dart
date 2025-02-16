import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/data/series_data.dart';
import '../../../../../model/series/series_def.dart';
import 'blood_pressure_value_renderer.dart';

class SeriesDataBloodPressureDotsView extends StatelessWidget {
  const SeriesDataBloodPressureDotsView({super.key, required this.seriesDef, required this.seriesData});

  final SeriesDef seriesDef;
  final SeriesData<BloodPressureValue> seriesData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text("TODO Dots for ${seriesDef.name} ${seriesData.seriesItems.length}"),
        ...seriesData.seriesItems.map(
          (e) => BloodPressureValueRenderer(bloodPressureValue: e),
        ),
      ],
    );
  }
}
