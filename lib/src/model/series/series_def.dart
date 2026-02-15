import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../util/color_utils.dart';
import '../../util/ex.dart';
import '../../util/json_reader.dart';
import '../../widgets/controls/navigation/hide_bottom_navigation_bar.dart';
import '../../widgets/controls/select/icon_map.dart';
import '../../widgets/series/edit/series_edit.dart';
import '../column_profile/column_profile.dart';
import 'seriesItem/calculated/calculation_item_series_value.dart';
import 'seriesItem/series_item.dart';
import 'series_type.dart';
import 'settings/blood_pressure_settings.dart';
import 'settings/custom/custom_attributes_settings.dart';
import 'settings/custom/custom_settings.dart';
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
  }) : color = color ?? seriesType.color,
       _settings = settings ?? {};

  /// return BloodPressureSettings in edit mode (setters active)
  BloodPressureSettings bloodPressureSettingsEditable(Function() updateStateCB) => BloodPressureSettings(_settings, updateStateCB);

  /// return BloodPressureSettings read only mode
  BloodPressureSettings bloodPressureSettingsReadonly() => BloodPressureSettings(_settings, null);

  /// return CustomSettings in edit mode (setters active)
  CustomSettings customSettingsEditable(Function() updateStateCB) => CustomSettings(_settings, updateStateCB);

  /// return CustomSettings read only mode
  CustomSettings customSettingsReadonly() => CustomSettings(_settings, null);

  /// return customAttributes in edit mode (setters active)
  CustomAttributesSettings customAttributesSettingsEditable(Function() updateStateCB) => CustomAttributesSettings(_settings, updateStateCB);

  /// return customAttributes read only mode
  CustomAttributesSettings customAttributesSettingsReadonly() => CustomAttributesSettings(_settings, null);

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
    return SeriesDef.fromJson(JsonReader(jsonDecode(jsonEncode(toJson()))), ignoreValidation: ignoreValidation);
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

  factory SeriesDef.fromJson(JsonReader json, {bool ignoreValidation = false}) {
    SeriesType seriesType;
    var jType = json.asReader('seriesType');
    try {
      seriesType = SeriesType.byName(jType.getString());
    } catch (err) {
      throw JsonParseException('Invalid value at ${jType.pathString} - $err');
    }

    var seriesDef = SeriesDef(
      uuid: json.asStringOr('uuid', const Uuid().v4()),
      seriesType: seriesType,
      seriesItems: [...(json.asReader('seriesItems').asReaders().map((e) => SeriesItem.fromJson(e)))],
      name: json.asString('name'),
      color: ColorUtils.fromHex(json.asString('color')),
      iconName: json.asStringOrNull('iconName'),
      settings: json.asMapOrNull('settings'),
    );

    // validate settings
    if (!ignoreValidation) {
      DailyLifeAttributesSettings.validate(seriesDef);
    }

    return seriesDef;
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'seriesType': seriesType.name,
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
        if (customAttributesSettingsReadonly().attributes.isNotEmpty) {
          headers.add("attribute");
        }
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

  /// validates the series (to be called after import)
  void validate() {
    // validate references
    if (seriesType == SeriesType.custom || seriesType == SeriesType.monthly) {
      if (seriesItems.isEmpty) throw Ex("Invalid (empty) series items.");
      if (seriesItems.where((element) => !element.hideInTable).isEmpty) throw Ex("At least one series item must be active for table view.");
      if (seriesItems.where((element) => !element.hideInChart).isEmpty) throw Ex("At least one series item must be active for chart view.");

      var validSiids = seriesItems.where((si) => !si.isCalculated).map((si) => si.siid).toSet();
      for (var seriesItem in seriesItems) {
        if (seriesItem.isCalculated) {
          var sourceSiid = seriesItem.calculationContainer!.sourceSiid;
          if (!validSiids.contains(sourceSiid)) {
            throw Ex("Invalid sourceSiid '$sourceSiid' found in series ${seriesItem.name} - valid: $validSiids");
          }
          List<CalculationItemSeriesValue> workList = [...seriesItem.calculationContainer!.calculationItems.whereType<CalculationItemSeriesValue>()];
          while (workList.isNotEmpty) {
            var calcItem = workList.removeAt(0);
            sourceSiid = calcItem.calculationContainer.sourceSiid;
            if (!validSiids.contains(sourceSiid)) {
              throw Ex("Invalid sourceSiid '$sourceSiid' found in series ${seriesItem.name} - valid: $validSiids");
            }
            workList.addAll(calcItem.calculationContainer.calculationItems.whereType<CalculationItemSeriesValue>());
          }
        }
      }
    }
  }
}
