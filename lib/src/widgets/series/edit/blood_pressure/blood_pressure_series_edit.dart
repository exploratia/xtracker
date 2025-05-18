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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(LocaleKeys.series_edit_bloodPressure_labels_hideTabletInput.tr()),
            Switch(value: settings.hideTabletInput, onChanged: (value) => settings.hideTabletInput = value),
          ],
        )
      ],
    );
  }
}
