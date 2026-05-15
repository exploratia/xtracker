import 'package:uuid/uuid.dart';

import '../../../../util/ex.dart';
import '../../../../util/globals.dart';
import '../../../../util/json_reader.dart';
import '../../series_def.dart';
import '../series_data_value.dart';

class CustomValue extends SeriesDataValue {
  final Map<String, double> values;
  final String? tagId;

  CustomValue(super.uuid, super.dateTime, this.values, this.tagId);

  @override
  Map<String, dynamic> toJson({bool exportUuid = true}) => {
    if (exportUuid) 'uuid': uuid,
    'utcMs': dateTime.millisecondsSinceEpoch,
    'values': values,
    if (tagId != null) 'tagId': tagId,
  };

  factory CustomValue.fromJson(JsonReader json) {
    Map<String, double> values = {};
    var jValues = json.asReaderOrNull('values');
    if (jValues != null) {
      for (var entry in jValues.asMapReaders()) {
        values[entry.key] = entry.value.getDouble();
      }
    }
    return CustomValue(
      json.asStringOr('uuid', const Uuid().v4()),
      DateTime.fromMillisecondsSinceEpoch(json.asReader('utcMs').getInt()),
      values,
      json.asStringOrNull("tagId"),
    );
  }

  @override
  List<dynamic> toCSVList(SeriesDef seriesDef) {
    List<dynamic> list = [dateTime.millisecondsSinceEpoch];
    for (var seriesItem in seriesDef.seriesItems) {
      list.add(values[seriesItem.siid]);
    }

    String tagName = Globals.invalid;
    var tags = seriesDef.customTagsSettingsReadonly().tags;
    for (var tag in tags) {
      if (tag.tagId == tagId) tagName = tag.name;
    }
    list.add(tagName);

    return list;
  }

  factory CustomValue.fromCSVList(List<dynamic> csv, SeriesDef seriesDef) {
    Map<String, double> values = {};
    int idx = 0;
    for (var seriesItem in seriesDef.seriesItems) {
      idx++;
      if (csv.length > idx) {
        var val = csv[idx];
        if (val is double) {
          values[seriesItem.siid] = val;
        } else if (val is int) {
          values[seriesItem.siid] = val.toDouble();
        }
      }
    }

    String? tagId;
    {
      // build resolver map
      var tags = seriesDef.customTagsSettingsReadonly().tags;
      Map<String, String> tagName2TagId = {};
      for (var tag in tags) {
        tagName2TagId[tag.name] = tag.tagId;
      }
      idx++;
      tagId = tagName2TagId[csv[idx]];
    }

    return CustomValue(
      const Uuid().v4().toString(),
      DateTime.fromMillisecondsSinceEpoch(csv[0] as int),
      values,
      tagId,
    );
  }

  @override
  String toString() {
    return 'CustomValue{...}';
  }

  static CustomValue checkOnCustomValue(dynamic value) {
    if (value is CustomValue) return value;
    var errMsg = 'Failure for series value: Type mismatch! Expected: "$CustomValue", got: "${value.runtimeType}"';
    throw Ex(errMsg);
  }
}
