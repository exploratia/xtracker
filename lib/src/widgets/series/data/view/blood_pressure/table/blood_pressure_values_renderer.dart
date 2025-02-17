import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import 'blood_pressure_value_renderer.dart';

class BloodPressureValuesRenderer extends StatelessWidget {
  const BloodPressureValuesRenderer({super.key, required this.bloodPressureValues});

  final List<BloodPressureValue> bloodPressureValues;

  @override
  Widget build(BuildContext context) {
    if (bloodPressureValues.isEmpty) return Container();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...bloodPressureValues.map((bpv) => BloodPressureValueRenderer(bloodPressureValue: bpv)),
      ],
    );
  }
}
