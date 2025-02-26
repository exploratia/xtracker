import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/i18n.dart';
import '../../widgets/navigation/hide_bottom_navigation_bar.dart';
import '../../widgets/select/icon_map.dart';
import '../../widgets/series/edit/series_edit.dart';
import 'series_type.dart';

class SeriesDef {
  final String uuid;

  final SeriesType seriesType;
  final List<SeriesItem> seriesItems;
  String name = "";
  Color color = Colors.red;
  String iconName = "";

  SeriesDef({required this.uuid, required this.seriesType, this.name = "", Color? color, required this.seriesItems})
      : color = color ?? seriesType.color,
        iconName = seriesType.iconName;

  @override
  String toString() {
    return 'SeriesDef{uuid: $uuid, seriesType: $seriesType, name: $name, color: $color, iconName: $iconName}';
  }

  Icon icon() {
    return Icon(iconData(), color: color);
  }

  IconData iconData() {
    return IconMap.iconData(iconName);
  }

  static Future<SeriesDef?> addNewSeries(BuildContext context) async {
    final themeData = Theme.of(context);

    SeriesDef? editedSeriesDef = await showDialog<SeriesDef>(
        context: context,
        builder: (context) => Dialog.fullscreen(
            backgroundColor: themeData.scaffoldBackgroundColor,
            child: const HideBottomNavigationBar(
              child: SeriesEdit(seriesDef: null),
            )));
    return editedSeriesDef;
  }
}

class SeriesItem {
  final String uuid;
  late String title;
  final String unit;
  final String? msgId;
  final double tableColumnMinWidth;

  SeriesItem({required this.uuid, required this.title, this.msgId, required this.unit, required this.tableColumnMinWidth});

  String getTitle(AppLocalizations t) {
    var titleStr = msgId != null ? (I18N.compose(msgId, t) ?? title) : title;
    return titleStr;
  }

  static List<SeriesItem> bloodPressureSeriesItems() {
    return [
      SeriesItem(
        uuid: '00000000-0000-0000-0000-000000000001',
        title: '',
        msgId: I18N.bloodPressureSeriesItemTitleDiastolic,
        unit: 'mmHg',
        tableColumnMinWidth: 80,
      ),
      SeriesItem(
        uuid: '00000000-0000-0000-0000-000000000002',
        title: '',
        msgId: I18N.bloodPressureSeriesItemTitleSystolic,
        unit: 'mmHg',
        tableColumnMinWidth: 80,
      )
    ];
  }
}
