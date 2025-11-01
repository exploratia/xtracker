import 'dart:math';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/day_item/day_item.dart';
import '../../../../series/data/view/blood_pressure/table/blood_pressure_value_renderer.dart';
import '../pixel.dart';
import 'grid_day_item.dart';

class BloodPressureDayItem extends GridDayItem<BloodPressureValue> {
  int high = -1000;
  int low = 1000;
  bool medication = false;

  BloodPressureDayItem(super.dateTimeDayStart, super.seriesDef);

  void updateHighLow(int valH, int valL, bool med) {
    high = max(high, valH);
    low = min(low, valL);
    medication |= med;
  }

  Pixel toPixel(bool monthly) {
    String? pixelText;
    if (count > 1) pixelText = '$count';
    if (medication) {
      if (pixelText == null) {
        pixelText = "+";
      } else {
        pixelText += "+";
      }
    }

    return Pixel<BloodPressureValue>(
      colors: [BloodPressureValue.colorLow(low), BloodPressureValue.colorHigh(high)],
      verticalGradient: true,
      backgroundColor: backgroundColor,
      pixelText: pixelText,
      isStartMarker: monthly ? false : dayDate.day == 1,
      seriesValues: dateTimeItems,
      tooltipValueBuilder: (dataValue) => BloodPressureValueRenderer(bloodPressureValue: dataValue, seriesDef: seriesDef),
    );
  }

  @override
  String toString() {
    return 'BloodPressureDayItem{date: $dayDate, high: $high, low: $low, medication: $medication, count: $count}';
  }

  static List<BloodPressureDayItem> buildDayItems(List<BloodPressureValue> seriesData, SeriesDef seriesDef) {
    List<BloodPressureDayItem> list = DayItem.buildDayItems(
      seriesData,
      (DateTime dayDate) => BloodPressureDayItem(dayDate, seriesDef),
      reversed: true /*reversed - we want to see newest date first*/,
    );

    // Update day values
    for (var dayItem in list) {
      for (var bloodPressureValue in dayItem.dateTimeItems) {
        dayItem.updateHighLow(bloodPressureValue.high, bloodPressureValue.low, bloodPressureValue.medication);
      }
    }

    return list;
  }
}
