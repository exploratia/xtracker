import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../model/series/series_type.dart';
import '../../controls/card/expandable.dart';

class SeriesEditDisplaySettings extends StatelessWidget {
  static final List<SeriesType> _allowedSeriesTypes = [SeriesType.bloodPressure, SeriesType.dailyCheck];

  static bool applicableOn(SeriesDef seriesDef) {
    return _allowedSeriesTypes.contains(seriesDef.seriesType);
  }

  final SeriesDef seriesDef;
  final Function() updateStateCB;

  const SeriesEditDisplaySettings(this.seriesDef, this.updateStateCB, {super.key});

  @override
  Widget build(BuildContext context) {
    var settings = seriesDef.displaySettingsEditable(updateStateCB);
    var seriesType = seriesDef.seriesType;

    return Expandable(
      icon: const Icon(Icons.settings_outlined),
      title: LocaleKeys.seriesEdit_common_displaySettings_title.tr(),
      child: Column(
        children: [
          if (seriesType == SeriesType.dailyCheck || seriesType == SeriesType.bloodPressure)
            SwitchListTile(
              title: Text(
                LocaleKeys.seriesEdit_common_displaySettings_switch_dotsViewShowCount_label.tr(),
              ),
              value: settings.dotsViewShowCount,
              onChanged: (value) => settings.dotsViewShowCount = value,
              secondary: const Icon(Icons.numbers_outlined),
            ),
        ],
      ),
    );
  }
}
