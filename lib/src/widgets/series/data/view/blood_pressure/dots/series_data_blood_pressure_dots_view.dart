import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/custom_paint_utils.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../controls/dots/responsive_dots_view.dart';

class SeriesDataBloodPressureDotsView extends StatelessWidget {
  const SeriesDataBloodPressureDotsView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesViewMetaData seriesViewMetaData;
  final SeriesData<BloodPressureValue> seriesData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final Map<String, _BloodPressureDayItem> data = _buildDataProvider(seriesData);
    DateTime minDateTime = DateTime.now();
    DateTime maxDateTime = DateTime.now();
    if (seriesData.data.isNotEmpty) {
      minDateTime = seriesData.data.first.dateTime;
      maxDateTime = seriesData.data.last.dateTime;
    }

    painterFnc(_BloodPressureDayItem dataItem, Canvas canvas, Offset topLeft, Offset bottomRight) {
      List<Color> colors = [BloodPressureValue.colorHigh(dataItem.high), BloodPressureValue.colorLow(dataItem.low)];
      final rect = Rect.fromPoints(topLeft, bottomRight);
      CustomPaintUtils.paintGradientFilledRect(canvas, rect, 2, colors, Alignment.topCenter, Alignment.bottomCenter);
      if (dataItem.medication) {
        // draw a small cross as medication indicator
        var medicationPaint = Paint()..color = themeData.textTheme.labelMedium?.color ?? Colors.white;
        var crossCenter = rect.topRight.translate(-3.5, 3.5);
        canvas.drawRect(Rect.fromCenter(center: crossCenter, width: 5, height: 1), medicationPaint);
        canvas.drawRect(Rect.fromCenter(center: crossCenter, width: 1, height: 5), medicationPaint);
      }
    }

    return ResponsiveDotsView(
      minDateTime: minDateTime,
      maxDateTime: maxDateTime,
      data: data,
      showCount: seriesViewMetaData.seriesDef.displaySettingsReadonly().dotsViewShowCount,
      painterFnc: painterFnc,
    );
  }

  Map<String, _BloodPressureDayItem> _buildDataProvider(SeriesData<BloodPressureValue> seriesData) {
    Map<String, _BloodPressureDayItem> map = {};

    for (var item in seriesData.data) {
      String dateDay = DateTimeUtils.formateDate(item.dateTime);
      _BloodPressureDayItem? actItem = map[dateDay];
      if (actItem == null) {
        actItem = _BloodPressureDayItem();
        map[dateDay] = actItem;
      } else {
        actItem.increaseCount();
      }
      actItem.updateHighLow(item.high, item.low, item.medication);
    }

    return map;
  }
}

class _BloodPressureDayItem extends DayItem {
  int high = -1000;
  int low = 1000;
  bool medication = false;

  _BloodPressureDayItem();

  void updateHighLow(int valH, int valL, bool med) {
    high = max(high, valH);
    low = min(low, valL);
    medication |= med;
  }

  @override
  String toString() {
    return '_BloodPressureDayItem{high: $high, low: $low, count: $count}';
  }
}
