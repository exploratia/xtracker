import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../widgets/navigation/hide_bottom_navigation_bar.dart';
import '../../widgets/series/edit/series_edit.dart';
import 'series_type.dart';

class SeriesDef {
  final String uuid = const Uuid().v4();
  final SeriesType seriesType;
  String name = "";
  Color color = Colors.red;
  String iconName = "";

  SeriesDef({required this.seriesType})
      : color = seriesType.color,
        iconName = seriesType.iconName;

  @override
  String toString() {
    return 'SeriesDef{uuid: $uuid, seriesType: $seriesType, name: $name, color: $color, iconName: $iconName}';
  }

  static Future<SeriesDef?> addNewSeries(BuildContext context) async {
    SeriesDef? editedSeriesDef = await showDialog<SeriesDef>(
        context: context,
        builder: (context) => const Dialog.fullscreen(
            child:
                HideBottomNavigationBar(child: SeriesEdit(seriesDef: null))));
    return editedSeriesDef;
  }
}
