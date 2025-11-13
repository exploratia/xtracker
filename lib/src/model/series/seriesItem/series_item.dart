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

  final bool calculatedItem;
  final CalculationContainer? calculationContainer;

  SeriesItem({
    required this.siid,
    required this.name,
    required this.unit,
    required this.color,
    // extended
    required this.hideInTable,
    required this.hideInChart,
    this.tableColumnWidth,
    required this.calculatedItem,
    this.calculationContainer,
  });

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

  /// check if this series item is a calculated one and references the given siid.
  bool references(String siid) {
    if (!calculatedItem || calculationContainer == null) return false;
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
    var calculatedItem = json['calculatedItem'] as bool? ?? false;
    return SeriesItem(
      siid: json['siid'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String?,
      color: ColorUtils.fromHex(json['color'] as String),
      // extended
      hideInTable: json['hideInTable'] as bool? ?? false,
      hideInChart: json['hideInChart'] as bool? ?? false,
      tableColumnWidth: json['tableColumnWidth'] as int?,
      calculatedItem: calculatedItem,
      calculationContainer: calculatedItem ? CalculationContainer.fromJson(json['seriesValue'] as Map<String, dynamic>) : null,
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
    if (calculatedItem) json['calculatedItem'] = true;
    if (calculatedItem && calculationContainer != null) json['seriesValue'] = calculationContainer!.toJson();

    return json;
  }
}
