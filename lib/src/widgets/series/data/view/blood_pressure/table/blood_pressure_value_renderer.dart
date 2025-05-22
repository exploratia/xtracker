import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';

class BloodPressureValueRenderer extends StatelessWidget {
  const BloodPressureValueRenderer({super.key, required this.bloodPressureValue, this.editMode, required this.seriesDef});

  final BloodPressureValue bloodPressureValue;
  final bool? editMode;
  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    var container = Container(
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
        children: [
          SizedBox(width: 30, child: Text('${bloodPressureValue.high}', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)),
          bloodPressureValue.medication
              ? const Icon(
                  Icons.medication_outlined,
                  size: 16,
                  color: Colors.white,
                )
              : const SizedBox(height: 16, child: VerticalDivider(thickness: 1, width: 8, color: Colors.white)),
          SizedBox(width: 30, child: Text('${bloodPressureValue.low}', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)),
        ],
      ),
    );

    if (editMode != null && editMode!) {
      return InkWell(
        onTap: () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: bloodPressureValue),
        child: container,
      );
    }
    return container;
  }
}
