import 'package:flutter/material.dart';

import '../../widgets/navigation/hide_bottom_navigation_bar.dart';
import '../../widgets/series/edit/series_edit.dart';
import 'series_type.dart';

class SeriesDef {
  final String uuid = "0123456"; // TODO UUID
  final SeriesType seriesType;
  String name = "";

  SeriesDef({required this.seriesType});

  static Future<SeriesDef?> addNewSeries(BuildContext context) async {
    SeriesDef? editedSeriesDef = await showDialog<SeriesDef>(
        context: context,
        builder: (context) => const Dialog.fullscreen(
            child:
                HideBottomNavigationBar(child: SeriesEdit(seriesDef: null))));
    return editedSeriesDef;
  }
}
