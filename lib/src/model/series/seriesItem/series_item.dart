import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../util/color_utils.dart';
import '../../../util/json_reader.dart';
import 'calculated/calculation_container.dart';
import 'calculated/calculation_item_series_value.dart';

class SeriesItem {
  final String siid;
  final String name;
  final String? unit;
  final Color color;

  // extended settings
  final bool hideInTable;
  final bool hideInChart;
  final int? tableColumnWidth;
  final bool useDeltaInChart;
  final CalculationContainer? calculationContainer;

  SeriesItem(
    this.siid,
    this.name,
    this.unit,
    this.color,
    // extended
    this.hideInTable,
    this.hideInChart,
    this.tableColumnWidth,
    this.useDeltaInChart,
    this.calculationContainer,
  );

  bool get isCalculated => calculationContainer != null;

  String unitInBrackets({bool emptyStringIfNullOrEmpty = false, String prefix = ' '}) {
    if (unit == null || unit != null && unit!.isEmpty) {
      if (emptyStringIfNullOrEmpty) return '';
      return "$prefix( )";
    }
    return '$prefix($unit)';
  }

  /// deep copy / clone by transforming to json string and back
  SeriesItem clone() {
    return SeriesItem.fromJson(JsonReader(jsonDecode(jsonEncode(toJson()))));
  }

  /// copy with given table settings
  SeriesItem withTableSettings(bool hideInTable, int? tableColumnWidth) {
    return SeriesItem(siid, name, unit, color, hideInTable, hideInChart, tableColumnWidth ?? this.tableColumnWidth, useDeltaInChart, calculationContainer);
  }

  /// copy with given chart settings
  SeriesItem withChartSettings(bool hideInChart, bool useDeltaInChart) {
    return SeriesItem(siid, name, unit, color, hideInTable, hideInChart, tableColumnWidth, useDeltaInChart, calculationContainer);
  }

  /// check if this series item is a calculated one and references the given siid.
  bool references(String siid) {
    if (calculationContainer == null) return false;
    if (calculationContainer!.sourceSiid == siid) return true;
    List<CalculationItemSeriesValue> worklist = [...calculationContainer!.calculationItems.whereType<CalculationItemSeriesValue>()];
    while (worklist.isNotEmpty) {
      CalculationItemSeriesValue item = worklist.removeAt(0);
      if (item.calculationContainer.sourceSiid == siid) return true;
      worklist.addAll([...item.calculationContainer.calculationItems.whereType<CalculationItemSeriesValue>()]);
    }
    return false;
  }

  factory SeriesItem.fromJson(JsonReader json) {
    var jCalculation = json.atOrNull("calculation");
    return SeriesItem(
      json.at('siid').getString(),
      json.at('name').getString(),
      json.atAsStringOrNull('unit'),
      ColorUtils.fromHex(json.at('color').getString()),
      // extended
      json.atAsBoolOr('hideInTable', false),
      json.atAsBoolOr('hideInChart', false),
      json.atAsIntOrNull('tableColumnWidth'),
      json.atAsBoolOr('useDeltaInChart', false),
      jCalculation != null ? CalculationContainer.fromJson(jCalculation) : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'siid': siid,
      'name': name,
      'unit': unit,
      'color': ColorUtils.toHex(color),
    };
    // extended
    if (hideInTable) json['hideInTable'] = true;
    if (hideInChart) json['hideInChart'] = true;
    if (tableColumnWidth != null) json['tableColumnWidth'] = tableColumnWidth;
    if (useDeltaInChart) json['useDeltaInChart'] = true;
    if (calculationContainer != null) json['calculation'] = calculationContainer!.toJson();

    return json;
  }
}
