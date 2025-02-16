import 'package:flutter/material.dart';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';

class BloodPressureValueRenderer extends StatelessWidget {
  const BloodPressureValueRenderer({super.key, required this.bloodPressureValue});

  final BloodPressureValue bloodPressureValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Theme.of(context).cardColor),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        gradient: LinearGradient(
          colors: [
            BloodPressureValue.colorHighOf(bloodPressureValue),
            BloodPressureValue.colorLowOf(bloodPressureValue),
          ],
        ),
        // borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        '${bloodPressureValue.high} | ${bloodPressureValue.low}',
        textAlign: TextAlign.center,
      ),
    );
  }
}
