import 'dart:convert';

import 'package:flutter/material.dart';

import '../../util/color_utils.dart';
import '../../widgets/controls/navigation/hide_bottom_navigation_bar.dart';
import '../../widgets/controls/select/icon_map.dart';
import '../../widgets/series/edit/series_edit.dart';
import 'series_type.dart';
import 'settings/blood_pressure_settings.dart';
import 'settings/display_settings.dart';

class SeriesDef {
  final String uuid;

  final SeriesType seriesType;
  final List<SeriesItem> seriesItems;
  String name = "";
  Color color = Colors.red;
  String iconName = "";
  final Map<String, dynamic> _settings;

  SeriesDef({
    required this.uuid,
    required this.seriesType,
    this.name = "",
    Color? color,
    String? iconName,
    required this.seriesItems,
    Map<String, dynamic>? settings,
  })  : color = color ?? seriesType.color,
        iconName = iconName ?? seriesType.iconName,
        _settings = settings ?? {};

  /// return BloodPressureSettings in edit mode (setters active)
  BloodPressureSettings bloodPressureSettingsEditable(Function() updateStateCB) => BloodPressureSettings(_settings, updateStateCB);

  /// return BloodPressureSettings read only mode
  BloodPressureSettings bloodPressureSettingsReadonly() => BloodPressureSettings(_settings, null);

  /// return BloodPressureSettings in edit mode (setters active)
  DisplaySettings displaySettingsEditable(Function() updateStateCB) => DisplaySettings(_settings, updateStateCB);

  /// return BloodPressureSettings read only mode
  DisplaySettings displaySettingsReadonly() => DisplaySettings(_settings, null);

  @override
  String toString() {
    return 'SeriesDef{uuid: $uuid, seriesType: $seriesType, name: $name, color: $color, iconName: $iconName}';
  }

  String toLogString() {
    return "Series {name: '$name', uuid: '$uuid', seriesType: '$seriesType'}";
  }

  /// deep copy / clone by transforming to json string and back
  SeriesDef clone() {
    return SeriesDef.fromJson(jsonDecode(jsonEncode(toJson())));
  }

  /// returns act/expected json version per series type (to be able to handle different parsings depending on version)
  ///
  /// 1: initial (all)
  static int seriesDefVersionByType(SeriesDef seriesDef) {
    return switch (seriesDef.seriesType) {
      SeriesType.bloodPressure => 1,
      SeriesType.dailyCheck => 1,
      SeriesType.habit => 1,
      // SeriesType.monthly => 1,
      // SeriesType.free => 1,
    };
  }

  Icon icon({double? size}) {
    return Icon(iconData(), color: color, size: size);
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
        iconName: json['iconName'] as String,
        settings: json['settings'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'seriesType': seriesType.typeName,
        'seriesItems': [...seriesItems.map((e) => e.toJson())],
        'name': name,
        'color': ColorUtils.toHex(color),
        'iconName': iconName,
        'settings': _settings,
        // type & version - could be used for parsing
        'type': 'seriesDef',
        'version': seriesDefVersionByType(this),
      };

  static Future<SeriesDef?> addNewSeries(BuildContext context) async {
    return _showSeriesEdit(null, context);
  }

  static Future<SeriesDef?> editSeries(SeriesDef seriesDef, BuildContext context) async {
    return _showSeriesEdit(seriesDef, context);
  }

  static Future<SeriesDef?> _showSeriesEdit(SeriesDef? seriesDef, BuildContext context) async {
    SeriesDef? editedSeriesDef = await showDialog<SeriesDef>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: HideBottomNavigationBar(
          child: SeriesEdit(seriesDef: seriesDef),
        ),
      ),
    );
    return editedSeriesDef;
  }
}

class SeriesItem {
  final String uuid;
  final String title;
  final String unit;
  final double tableColumnMinWidth;

  SeriesItem({required this.uuid, required this.title, required this.unit, required this.tableColumnMinWidth});

  String getTitle() {
    // if special case blood pressure is necessary:
    // if(uuid=='00000000-0000-0000-0000-000000000001') return I18N.bloodPressureSeriesItemTitleDiastolic.tr();
    // if(uuid=='00000000-0000-0000-0000-000000000002') return I18N.bloodPressureSeriesItemTitleSystolic.tr();
    return title;
  }

  factory SeriesItem.fromJson(Map<String, dynamic> json) => SeriesItem(
        uuid: json['uuid'] as String,
        title: json['title'] as String,
        unit: json['unit'] as String,
        tableColumnMinWidth: json['tableColumnMinWidth'] as double,
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'title': title,
        'unit': unit,
        'tableColumnMinWidth': tableColumnMinWidth,
      };

  static List<SeriesItem> bloodPressureSeriesItems() {
    return [
      SeriesItem(
        uuid: '00000000-0000-0000-0000-000000000001',
        title: 'Diastolic',
        unit: 'mmHg',
        tableColumnMinWidth: 80,
      ),
      SeriesItem(
        uuid: '00000000-0000-0000-0000-000000000002',
        title: 'Systolic',
        unit: 'mmHg',
        tableColumnMinWidth: 80,
      )
    ];
  }
}
