import 'package:flutter/material.dart';

import '../../../../model/series/series_def.dart';

class CustomSeriesEdit extends StatelessWidget {
  final SeriesDef seriesDef;
  final Function() updateStateCB;

  const CustomSeriesEdit(this.seriesDef, this.updateStateCB, {super.key});

  @override
  Widget build(BuildContext context) {
    // var settings = seriesDef.customSettingsEditable(updateStateCB);
    return const Column(
      children: [],
    );
  }
}
