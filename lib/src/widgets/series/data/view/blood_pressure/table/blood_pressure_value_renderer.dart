import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';

class BloodPressureValueRenderer extends StatelessWidget {
  const BloodPressureValueRenderer({super.key, required this.bloodPressureValue, this.editMode = false, required this.seriesDef});

  final BloodPressureValue bloodPressureValue;
  final bool editMode;
  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    Widget value;
    if (editMode) {
      value = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          onTap: () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: bloodPressureValue),
          child: _Value(bloodPressureValue: bloodPressureValue),
        ),
      );
    } else {
      value = _Value(bloodPressureValue: bloodPressureValue);
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: editMode ? themeData.colorScheme.secondary : themeData.cardColor),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        gradient: LinearGradient(
          colors: [
            BloodPressureValue.colorHighOf(bloodPressureValue),
            BloodPressureValue.colorLowOf(bloodPressureValue),
          ],
        ),
      ),
      child: value,
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.bloodPressureValue,
  });

  final BloodPressureValue bloodPressureValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
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
  }
}
