import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/custom_paint_utils.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../dots/responsive_dots_view.dart';

class SeriesDataBloodPressureDotsView extends StatelessWidget {
  const SeriesDataBloodPressureDotsView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesViewMetaData seriesViewMetaData;
  final SeriesData<BloodPressureValue> seriesData;

  @override
  Widget build(BuildContext context) {
    final Map<String, _BloodPressureDayItem> data = _buildDataProvider(seriesData);
    DateTime minDateTime = DateTime.now();
    DateTime maxDateTime = DateTime.now();
    if (seriesData.seriesItems.isNotEmpty) {
      minDateTime = seriesData.seriesItems.first.dateTime;
      maxDateTime = seriesData.seriesItems.last.dateTime;
    }

    painterFnc(_BloodPressureDayItem dataItem, Canvas canvas, Offset topLeft, Offset bottomRight) {
      List<Color> colors = [BloodPressureValue.colorHigh(dataItem.high), BloodPressureValue.colorLow(dataItem.low)];
      final rect = Rect.fromPoints(topLeft, bottomRight);
      CustomPaintUtils.paintGradientFilledRect(canvas, rect, colors, const Alignment(0, -1), const Alignment(0, 1));
    }

    return ResponsiveDotsView(
      minDateTime: minDateTime,
      maxDateTime: maxDateTime,
      data: data,
      painterFnc: painterFnc,
    );
  }

  Map<String, _BloodPressureDayItem> _buildDataProvider(SeriesData<BloodPressureValue> seriesData) {
    Map<String, _BloodPressureDayItem> map = {};

    for (var item in seriesData.seriesItems) {
      String dateDay = DateTimeUtils.formateDate(item.dateTime);
      _BloodPressureDayItem? actItem = map[dateDay];
      if (actItem == null) {
        actItem = _BloodPressureDayItem(dateTime: item.dateTime);
        map[dateDay] = actItem;
      }
      actItem.updateHighLow(item.high, item.low);
    }

    return map;
  }
}

class _BloodPressureDayItem extends DayItem {
  int high = -1000;
  int low = 1000;

  _BloodPressureDayItem({required super.dateTime});

  updateHighLow(int valH, int valL) {
    high = max(high, valH);
    low = min(low, valL);
  }

  @override
  String toString() {
    return '_BloodPressureDayItem{high: $high, low: $low}';
  }
}
