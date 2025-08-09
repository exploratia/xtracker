import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../controls/card/expandable.dart';

class SeriesEditDisplaySettings extends StatelessWidget {
  final SeriesDef seriesDef;
  final Function() updateStateCB;

  const SeriesEditDisplaySettings(this.seriesDef, this.updateStateCB, {super.key});

  @override
  Widget build(BuildContext context) {
    var settings = seriesDef.displaySettingsEditable(updateStateCB);

    return Expandable(
      icon: const Icon(Icons.settings_outlined),
      title: LocaleKeys.seriesEdit_common_displaySettings_title.tr(),
      child: Column(
        children: [
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
