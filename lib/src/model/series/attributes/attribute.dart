import 'dart:convert';
import 'dart:ui';

import '../../../util/color_utils.dart';
import '../../../util/json_reader.dart';

class Attribute {
  final String aid;
  final Color color;
  final String name;

  /// [aid] unique (per series) AttributeId
  Attribute({required this.aid, required this.color, required this.name});

  factory Attribute.fromJson(JsonReader json) => Attribute(
    aid: json.asString('aid'),
    name: json.asString('name'),
    color: ColorUtils.fromHex(json.asString('color')),
  );

  Map<String, dynamic> toJson() => {
    'aid': aid,
    'name': name,
    'color': ColorUtils.toHex(color),
  };

  /// deep copy / clone by transforming to json string and back
  Attribute clone() {
    return Attribute.fromJson(JsonReader(jsonDecode(jsonEncode(toJson()))));
  }

  static List<Attribute> parseJsonList(List<dynamic> json) {
    List<Attribute> attributes = [];
    for (var listItem in json) {
      attributes.add(Attribute.fromJson(JsonReader(listItem)));
    }
    return attributes;
  }

  static List<Map<String, dynamic>> toJsonList(List<Attribute> list) {
    return list.map((e) => e.toJson()).toList();
  }

  /// instead of Uuid creation for saving space we use milliseconds and convert it to base 36 String
  /// should be enough - attributes have to be unique only per series
  static String generateUniqueAttributeId({int? val}) {
    if (val != null) return val.toRadixString(36);
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }
}
