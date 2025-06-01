import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import 'blood_pressure_value_renderer.dart';

class BloodPressureValuesRenderer extends StatelessWidget {
  const BloodPressureValuesRenderer({super.key, required this.bloodPressureValues, required this.seriesViewMetaData, this.showBorder = false});

  final List<BloodPressureValue> bloodPressureValues;
  final SeriesViewMetaData seriesViewMetaData;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    if (bloodPressureValues.isEmpty) return Container();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...bloodPressureValues.map(
          (bpv) => BloodPressureValueRenderer(
            key: Key('bloodPressureValue_${bpv.uuid}'),
            bloodPressureValue: bpv,
            seriesDef: seriesViewMetaData.seriesDef,
            editMode: seriesViewMetaData.editMode,
            showBorder: showBorder,
          ),
        ),
      ],
    );
  }
}
