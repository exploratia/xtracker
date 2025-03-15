import 'package:flutter/material.dart';

import '../../../../model/series/series_def.dart';

class SeriesLatestValue extends StatelessWidget {
  const SeriesLatestValue({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return Text(seriesDef.uuid);
  }
}
