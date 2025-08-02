import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_def.dart';

class BloodPressureSeriesEdit extends StatelessWidget {
  final SeriesDef seriesDef;
  final Function() updateState;

  const BloodPressureSeriesEdit(this.seriesDef, this.updateState, {super.key});

  @override
  Widget build(BuildContext context) {
    var settings = seriesDef.bloodPressureSettings(updateState);
    return Column(
      children: [
        const Divider(height: 24),
        SwitchListTile(
          title: Text(
            LocaleKeys.seriesEdit_bloodPressure_label_hideMedicationInput.tr(),
          ),
          value: settings.hideMedicationInput,
          onChanged: (value) => settings.hideMedicationInput = value,
          secondary: const Icon(Icons.medication_outlined),
        ),
      ],
    );
  }
}
