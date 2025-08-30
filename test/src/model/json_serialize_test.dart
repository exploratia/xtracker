import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:xtracker/src/model/series/current_value/series_current_value.dart';
import 'package:xtracker/src/model/series/data/blood_pressure/blood_pressure_value.dart';
import 'package:xtracker/src/model/series/data/series_data.dart';
import 'package:xtracker/src/model/series/series_def.dart';
import 'package:xtracker/src/model/series/series_type.dart';
import 'package:xtracker/src/util/color_utils.dart';

void main() {
  group('SeriesCurrentValue', () {
    test('test serialize deserialize', () {
      var seriesDefUUId = const Uuid().v4().toString();
      var currentValueUUId = const Uuid().v4().toString();
      var dateTime = DateTime.now();
      SeriesCurrentValue currentValue =
          SeriesCurrentValue(seriesDefUUId, SeriesType.bloodPressure, BloodPressureValue(currentValueUUId, dateTime, 121, 81, true));
      var serialized = currentValue.toJson();
      var deserialized = SeriesCurrentValue.fromJson(serialized);

      expect(SeriesType.bloodPressure, deserialized.seriesType);
      expect(seriesDefUUId, deserialized.seriesDefUuid);
      expect(true, deserialized.seriesDataValue is BloodPressureValue);

      var deserializedValue = deserialized.seriesDataValue as BloodPressureValue;

      expect(currentValueUUId, deserializedValue.uuid);
      expect(dateTime.millisecondsSinceEpoch, deserializedValue.dateTime.millisecondsSinceEpoch);
      expect(121, deserializedValue.high);
      expect(81, deserializedValue.low);
      expect(true, deserializedValue.medication);
    });
  });

  group('SeriesDef', () {
    test('test serialize deserialize', () {
      var seriesDefUUId = const Uuid().v4().toString();
      SeriesDef seriesDef =
          SeriesDef(uuid: seriesDefUUId, seriesType: SeriesType.bloodPressure, seriesItems: [], color: Colors.red, iconName: "icoName", name: "SeriesName");
      var serialized = seriesDef.toJson();
      var deserialized = SeriesDef.fromJson(serialized);

      expect(SeriesType.bloodPressure, deserialized.seriesType);
      expect(seriesDefUUId, deserialized.uuid);
      expect(true, deserialized.seriesItems.isEmpty);
      expect(ColorUtils.toHex(Colors.red), ColorUtils.toHex(deserialized.color));
      expect("icoName", deserialized.iconName);
      expect("SeriesName", deserialized.name);
    });
  });

  group('SeriesData', () {
    test('test serialize deserialize', () {
      var seriesDefUUId = const Uuid().v4().toString();
      var currentValueUUId = const Uuid().v4().toString();
      var dateTime = DateTime.now();
      SeriesData seriesData = SeriesData<BloodPressureValue>(seriesDefUUId, []);
      seriesData.insert(BloodPressureValue(currentValueUUId, dateTime, 121, 81, true));
      var serialized = seriesData.toJson();
      var deserialized = SeriesData.fromJsonBloodPressureData(serialized);

      expect(seriesDefUUId, deserialized.seriesDefUuid);
      expect(true, deserialized.data.isNotEmpty);
      var deserializedBloodPressureValue = deserialized.data.first;
      expect(currentValueUUId, deserializedBloodPressureValue.uuid);
      expect(dateTime.millisecondsSinceEpoch, deserializedBloodPressureValue.dateTime.millisecondsSinceEpoch);
      expect(121, deserializedBloodPressureValue.high);
      expect(81, deserializedBloodPressureValue.low);
      expect(true, deserializedBloodPressureValue.medication);
    });
  });
}
