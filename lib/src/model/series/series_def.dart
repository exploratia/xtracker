import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/color_utils.dart';
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

  factory SeriesDef.fromJson(Map<String, dynamic> json) => SeriesDef(
        uuid: json['uuid'] as String,
        seriesType: SeriesType.byTypeName(json['seriesType'] as String),
        seriesItems: [...(json['seriesItems'] as List<dynamic>).whereType<Map<String, dynamic>>().map((e) => SeriesItem.fromJson(e))],
        name: json['name'] as String,
        color: ColorUtils.fromHex(json['color'] as String),
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'seriesType': seriesType.typeName,
        'seriesItems': [...seriesItems.map((e) => e.toJson())],
        'name': name,
        'color': ColorUtils.toHex(color),
        'iconName': iconName,
      };

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
  final String title;
  final String unit;
  final String? msgId;
  final double tableColumnMinWidth;

  SeriesItem({required this.uuid, required this.title, this.msgId, required this.unit, required this.tableColumnMinWidth});

  String getTitle(AppLocalizations t) {
    var titleStr = msgId != null ? (I18N.compose(msgId, t) ?? title) : title;
    return titleStr;
  }

  factory SeriesItem.fromJson(Map<String, dynamic> json) => SeriesItem(
        uuid: json['uuid'] as String,
        title: json['title'] as String,
        unit: json['unit'] as String,
        msgId: json['msgId'] == null ? null : json['msgId'] as String,
        tableColumnMinWidth: json['tableColumnMinWidth'] as double,
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'title': title,
        'unit': unit,
        'msgId': msgId,
        'tableColumnMinWidth': tableColumnMinWidth,
      };

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
