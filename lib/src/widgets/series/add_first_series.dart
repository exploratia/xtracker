import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/series/series_def.dart';

class AddFirstSeries extends StatelessWidget {
  const AddFirstSeries({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            tooltip: LocaleKeys.seriesDashboard_btn_addSeries_tooltip.tr(),
            iconSize: 40,
            color: themeData.colorScheme.primary,
            onPressed: () async {
              /*SeriesDef? s=*/ await SeriesDef.addNewSeries(context);
            },
            icon: const Icon(Icons.add_chart_outlined)),
        Center(child: Text(LocaleKeys.seriesDashboard_btn_addSeries_label.tr())),
      ],
    );
  }
}
