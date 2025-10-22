import 'dart:convert';
import 'dart:ui';

import '../../../../util/color_utils.dart';

class DailyLifeAttribute {
  final String aid;
  final Color color;
  final String name;

  /// [aid] unique (per series) AttributeId
  DailyLifeAttribute({required this.aid, required this.color, required this.name});

  factory DailyLifeAttribute.fromJson(Map<String, dynamic> json) => DailyLifeAttribute(
        aid: json['aid'] as String,
        name: json['name'] as String,
        color: ColorUtils.fromHex(json['color'] as String),
      );

  Map<String, dynamic> toJson() => {
        'aid': aid,
        'name': name,
        'color': ColorUtils.toHex(color),
      };

  /// deep copy / clone by transforming to json string and back
  DailyLifeAttribute clone() {
    return DailyLifeAttribute.fromJson(jsonDecode(jsonEncode(toJson())));
  }

  static List<DailyLifeAttribute> parseJsonList(List<dynamic> json) {
    List<DailyLifeAttribute> attributes = [];
    for (var listItem in json) {
      if (listItem is Map<String, dynamic>) {
        attributes.add(DailyLifeAttribute.fromJson(listItem));
      }
    }
    return attributes;
  }

  static List<Map<String, dynamic>> toJsonList(List<DailyLifeAttribute> list) {
    return list.map((e) => e.toJson()).toList();
  }

  /// instead of Uuid creation for saving space we use milliseconds and convert it to base 36 String
  /// should be enough - attributes have to be unique only per series
  static String generateUniqueAttributeId({int? val}) {
    if (val != null) return val.toRadixString(36);
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }
}
