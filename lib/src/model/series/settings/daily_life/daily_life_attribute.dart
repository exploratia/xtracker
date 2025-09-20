import 'dart:convert';
import 'dart:ui';

import '../../../../util/color_utils.dart';

class DailyLifeAttribute {
  final String uuid;
  final Color color;
  final String name;

  DailyLifeAttribute({required this.uuid, required this.color, required this.name});

  factory DailyLifeAttribute.fromJson(Map<String, dynamic> json) => DailyLifeAttribute(
        uuid: json['uuid'] as String,
        name: json['name'] as String,
        color: ColorUtils.fromHex(json['color'] as String),
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
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
}
