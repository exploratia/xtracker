import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../util/color_utils.dart';
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
    return SeriesItem.fromJson(jsonDecode(jsonEncode(toJson())));
  }

  /// copy with given value for hideInTable
  SeriesItem withHideInTable(bool value) {
    return SeriesItem(siid, name, unit, color, value, hideInChart, tableColumnWidth, calculationContainer);
  }

  /// copy with given value for hideInTable
  SeriesItem withHideInChart(bool value) {
    return SeriesItem(siid, name, unit, color, hideInTable, value, tableColumnWidth, calculationContainer);
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

  factory SeriesItem.fromJson(Map<String, dynamic> json) {
    return SeriesItem(
      json['siid'] as String,
      json['name'] as String,
      json['unit'] as String?,
      ColorUtils.fromHex(json['color'] as String),
      // extended
      json['hideInTable'] as bool? ?? false,
      json['hideInChart'] as bool? ?? false,
      json['tableColumnWidth'] as int?,
      json.containsKey("calculation") ? CalculationContainer.fromJson(json['calculation'] as Map<String, dynamic>) : null,
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
    if (calculationContainer != null) json['calculation'] = calculationContainer!.toJson();

    return json;
  }
}
