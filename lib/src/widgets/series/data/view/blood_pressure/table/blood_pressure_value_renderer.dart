import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';

class BloodPressureValueRenderer extends StatelessWidget {
  const BloodPressureValueRenderer({super.key, required this.bloodPressureValue});

  final BloodPressureValue bloodPressureValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO callback? dann klickable
      // width: 270,
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      decoration: BoxDecoration(
        // border: Border.all(width: 1, color: Theme.of(context).cardColor),
        // borderRadius: const BorderRadius.all(Radius.circular(4)),
        gradient: LinearGradient(
          colors: [
            BloodPressureValue.colorHighOf(bloodPressureValue),
            BloodPressureValue.colorLowOf(bloodPressureValue),
          ],
        ),
        // borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 4,
        children: [
          Text('${bloodPressureValue.high}', textAlign: TextAlign.center),
          const SizedBox(height: 16, child: VerticalDivider(thickness: 1, width: 1, color: Colors.white)),
          Text('${bloodPressureValue.low}', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
