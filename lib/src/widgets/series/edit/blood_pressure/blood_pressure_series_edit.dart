import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_def.dart';

class BloodPressureSeriesEdit extends StatelessWidget {
  final SeriesDef seriesDef;
  final Function() updateStateCB;

  const BloodPressureSeriesEdit(this.seriesDef, this.updateStateCB, {super.key});

  @override
  Widget build(BuildContext context) {
    var settings = seriesDef.bloodPressureSettingsEditable(updateStateCB);
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            LocaleKeys.seriesEdit_bloodPressure_switch_hideMedicationInput_label.tr(),
          ),
          value: settings.hideMedicationInput,
          onChanged: (value) => settings.hideMedicationInput = value,
          secondary: const Icon(Icons.medication_outlined),
        ),
      ],
    );
  }
}
