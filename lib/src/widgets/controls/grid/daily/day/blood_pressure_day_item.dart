import 'dart:math';

import '../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../model/series/data/series_data.dart';
import '../../../../../model/series/series_def.dart';
import '../../../../../util/date_time_utils.dart';
import '../dot.dart';
import './day_item.dart';

class BloodPressureDayItem extends DayItem {
  int high = -1000;
  int low = 1000;
  bool medication = false;

  static bool _showCount = false;

  /// set statics (colors,...) for Dot
  static void updateValuesFromSeries(SeriesDef seriesDef) {
    _showCount = seriesDef.displaySettingsReadonly().dotsViewShowCount;
  }

  BloodPressureDayItem(super.dateTimeDayStart);

  void updateHighLow(int valH, int valL, bool med) {
    high = max(high, valH);
    low = min(low, valL);
    medication |= med;
  }

  @override
  Dot toDot(bool monthly) {
    if (count < 1) return noValueDot(monthly);

    return Dot(
      dotColor1: BloodPressureValue.colorHigh(high),
      dotColor2: BloodPressureValue.colorLow(low),
      dotText: medication ? '+' : null,
      showCount: _showCount,
      isStartMarker: monthly ? false : dateTimeDayStart.day == 1,
      seriesValues: seriesValues,
    );
  }

  @override
  String toString() {
    return 'BloodPressureDayItem{date: $dateTimeDayStart, high: $high, low: $low, medication: $medication, count: $count}';
  }

  static List<BloodPressureDayItem> buildDayItems(SeriesData<BloodPressureValue> seriesData) {
    List<BloodPressureDayItem> list = [];

    BloodPressureDayItem? actItem;
    DateTime? actDay;

    BloodPressureDayItem createDayItem(DateTime dateTimeDayStart) {
      BloodPressureDayItem dayItem = BloodPressureDayItem(dateTimeDayStart);
      list.add(dayItem);
      return dayItem;
    }

    for (var item in seriesData.data.reversed) {
      DateTime dateDay = DateTimeUtils.truncateToDay(item.dateTime);
      actDay ??= dateDay;

      actItem ??= createDayItem(dateDay);

      // not matching date - create (empty)
      while (actDay!.isAfter(dateDay)) {
        actDay = DateTimeUtils.dayBefore(actDay);
        actItem = createDayItem(actDay);
      }

      actItem!.addValue(item);
      actItem.updateHighLow(item.high, item.low, item.medication);
    }

    return list;
  }
}
