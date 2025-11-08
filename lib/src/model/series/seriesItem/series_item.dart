import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../util/color_utils.dart';

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

  factory SeriesItem.fromJson(Map<String, dynamic> json) => SeriesItem(
        siid: json['siid'] as String,
        name: json['name'] as String,
        unit: json['unit'] as String?,
        color: ColorUtils.fromHex(json['color'] as String),
        // extended
        hideInTable: json['hideInTable'] as bool? ?? false,
        hideInChart: json['hideInChart'] as bool? ?? false,
        tableColumnWidth: json['tableColumnWidth'] as int?,
        calculatedItem: json['calculatedItem'] as bool? ?? false,
      );

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

    return json;
  }
}
