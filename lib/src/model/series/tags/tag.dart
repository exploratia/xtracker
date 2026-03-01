import 'dart:convert';
import 'dart:ui';

import '../../../util/color_utils.dart';
import '../../../util/json_reader.dart';

class Tag {
  final String tagId;
  final Color color;
  final String name;

  /// [tagId] unique (per series) TagId
  Tag({required this.tagId, required this.color, required this.name});

  factory Tag.fromJson(JsonReader json) => Tag(
    tagId: json.asString('tagId'),
    name: json.asString('name'),
    color: ColorUtils.fromHex(json.asString('color')),
  );

  Map<String, dynamic> toJson() => {
    'tagId': tagId,
    'name': name,
    'color': ColorUtils.toHex(color),
  };

  /// deep copy / clone by transforming to json string and back
  Tag clone() {
    return Tag.fromJson(JsonReader(jsonDecode(jsonEncode(toJson()))));
  }

  static List<Tag> parseJsonList(List<dynamic> json) {
    List<Tag> tags = [];
    for (var listItem in json) {
      tags.add(Tag.fromJson(JsonReader(listItem)));
    }
    return tags;
  }

  static List<Map<String, dynamic>> toJsonList(List<Tag> list) {
    return list.map((e) => e.toJson()).toList();
  }

  /// instead of Uuid creation for saving space we use milliseconds and convert it to base 36 String
  /// should be enough - tags have to be unique only per series
  static String generateUniqueTagId({int? val}) {
    if (val != null) return val.toRadixString(36);
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }
}
