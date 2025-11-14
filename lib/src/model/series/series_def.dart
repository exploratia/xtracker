import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../util/color_utils.dart';
import '../../widgets/controls/navigation/hide_bottom_navigation_bar.dart';
import '../../widgets/controls/select/icon_map.dart';
import '../../widgets/series/edit/series_edit.dart';
import '../column_profile/column_profile.dart';
import 'seriesItem/series_item.dart';
import 'series_type.dart';
import 'settings/blood_pressure_settings.dart';
import 'settings/custom_settings.dart';
import 'settings/daily_life/daily_life_attributes_settings.dart';
import 'settings/display_settings.dart';
import 'view_type.dart';

class SeriesDef {
  final String uuid;

  final SeriesType seriesType;
  final List<SeriesItem> seriesItems;
  String name = "";
  Color color = Colors.red;
  String? iconName;

  final Map<String, dynamic> _settings;

  SeriesDef({
    required this.uuid,
    required this.seriesType,
    this.name = "",
    Color? color,
    this.iconName,
    required this.seriesItems,
    Map<String, dynamic>? settings,
  })  : color = color ?? seriesType.color,
        _settings = settings ?? {};

  /// return BloodPressureSettings in edit mode (setters active)
  BloodPressureSettings bloodPressureSettingsEditable(Function() updateStateCB) => BloodPressureSettings(_settings, updateStateCB);

  /// return BloodPressureSettings read only mode
  BloodPressureSettings bloodPressureSettingsReadonly() => BloodPressureSettings(_settings, null);

  /// return CustomSettings in edit mode (setters active)
  CustomSettings customSettingsEditable(Function() updateStateCB) => CustomSettings(_settings, updateStateCB);

  /// return CustomSettings read only mode
  CustomSettings customSettingsReadonly() => CustomSettings(_settings, null);

  /// return dailyLifeAttributes in edit mode (setters active)
  DailyLifeAttributesSettings dailyLifeAttributesSettingsEditable(Function() updateStateCB) => DailyLifeAttributesSettings(_settings, updateStateCB);

  /// return dailyLifeAttributes read only mode
  DailyLifeAttributesSettings dailyLifeAttributesSettingsReadonly() => DailyLifeAttributesSettings(_settings, null);

  /// return DisplaySettings in edit mode (setters active)
  DisplaySettings displaySettingsEditable(Function() updateStateCB) => DisplaySettings(_settings, updateStateCB);

  /// return DisplaySettings read only mode
  DisplaySettings displaySettingsReadonly() => DisplaySettings(_settings, null);

  /// return FixColumnProfile from display settings or default for the series type (or null if the series has no fix column profile)
  ColumnProfile? get determineTableColumnProfile {
    // custom or monthly?
    if (seriesItems.isNotEmpty || seriesType == SeriesType.custom || seriesType == SeriesType.monthly) {
      return ColumnProfile.fromSeriesItems(this);
    }
    return displaySettingsReadonly().getTableViewColumnProfile(seriesType.defaultFixTableColumnProfileType);
  }

  /// return ViewType from display settings or default for the series type
  ViewType get determineViewType {
    return displaySettingsReadonly().getInitialViewType(seriesType.defaultViewType);
  }

  @override
  String toString() {
    return 'SeriesDef{uuid: $uuid, seriesType: $seriesType, name: $name, color: $color, iconName: $iconName}';
  }

  String toLogString() {
    return "Series {name: '$name', uuid: '$uuid', seriesType: '$seriesType'}";
  }

  /// deep copy / clone by transforming to json string and back
  /// [ignoreValidation] if set, validation is ignored
  SeriesDef clone({bool ignoreValidation = false}) {
    return SeriesDef.fromJson(jsonDecode(jsonEncode(toJson())), ignoreValidation: ignoreValidation);
  }

  /// returns act/expected json version per series type (to be able to handle different parsings depending on version)
  ///
  /// 1: initial (all)
  static int seriesDefVersionByType(SeriesDef seriesDef) {
    return switch (seriesDef.seriesType) {
      SeriesType.bloodPressure => 1,
      SeriesType.dailyCheck => 1,
      SeriesType.dailyLife => 1,
      SeriesType.habit => 1,
      SeriesType.custom => 1,
      SeriesType.monthly => 1,
    };
  }

  Icon icon({double? size}) {
    return Icon(iconData(), color: color, size: size);
  }

  IconData iconData() {
    return IconMap.iconData(iconName, seriesType.iconData);
  }

  factory SeriesDef.fromJson(Map<String, dynamic> json, {bool ignoreValidation = false}) {
    var seriesDef = SeriesDef(
      uuid: json['uuid'] as String? ?? const Uuid().v4(),
      seriesType: SeriesType.byTypeName(json['seriesType'] as String),
      seriesItems: [...(json['seriesItems'] as List<dynamic>).whereType<Map<String, dynamic>>().map((e) => SeriesItem.fromJson(e))],
      name: json['name'] as String,
      color: ColorUtils.fromHex(json['color'] as String),
      iconName: json['iconName'] as String?,
      settings: json['settings'] as Map<String, dynamic>?,
    );

    // validate settings
    if (!ignoreValidation) {
      DailyLifeAttributesSettings.validate(seriesDef);
    }

    return seriesDef;
  }

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

  List<dynamic> toCSVHeaderList() {
    List<dynamic> headers = ["utc(ms)"];
    switch (seriesType) {
      case SeriesType.bloodPressure:
        headers.addAll(["high", "low", "medication"]);
      case SeriesType.dailyCheck:
        {
          // nothing to do - only timestamp column
        }
      case SeriesType.habit:
        {
          // nothing to do - only timestamp column
        }
      case SeriesType.dailyLife:
        headers.add("attribute");
      case SeriesType.custom:
      case SeriesType.monthly:
        headers.addAll(seriesItems.map((e) => e.name));
    }

    return headers;
  }

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
