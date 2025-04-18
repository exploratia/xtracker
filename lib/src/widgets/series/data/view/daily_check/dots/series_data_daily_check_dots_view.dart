import 'package:flutter/material.dart';

import '../../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/color_utils.dart';
import '../../../../../../util/custom_paint_utils.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../dots/responsive_dots_view.dart';

class SeriesDataDailyCheckDotsView extends StatelessWidget {
  const SeriesDataDailyCheckDotsView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesViewMetaData seriesViewMetaData;
  final SeriesData<DailyCheckValue> seriesData;

  @override
  Widget build(BuildContext context) {
    final Map<String, _DailyCheckDayItem> data = _buildDataProvider(seriesData);
    DateTime minDateTime = DateTime.now();
    DateTime maxDateTime = DateTime.now();
    if (seriesData.seriesItems.isNotEmpty) {
      minDateTime = seriesData.seriesItems.first.dateTime;
      maxDateTime = seriesData.seriesItems.last.dateTime;
    }

    var color1 = seriesViewMetaData.seriesDef.color;
    var color2 = ColorUtils.hue(color1, 30);

    painterFnc(_DailyCheckDayItem dataItem, Canvas canvas, Offset topLeft, Offset bottomRight) {
      List<Color> colors = [color1, color2];
      final rect = Rect.fromPoints(topLeft, bottomRight);
      CustomPaintUtils.paintGradientFilledRect(canvas, rect, 2, colors, Alignment.topCenter, Alignment.bottomCenter);
    }

    return ResponsiveDotsView(
      minDateTime: minDateTime,
      maxDateTime: maxDateTime,
      data: data,
      painterFnc: painterFnc,
    );
  }

  Map<String, _DailyCheckDayItem> _buildDataProvider(SeriesData<DailyCheckValue> seriesData) {
    Map<String, _DailyCheckDayItem> map = {};

    for (var item in seriesData.seriesItems) {
      String dateDay = DateTimeUtils.formateDate(item.dateTime);
      map[dateDay] = _DailyCheckDayItem(dateTime: item.dateTime);
    }

    return map;
  }
}

class _DailyCheckDayItem extends DayItem {
  _DailyCheckDayItem({required super.dateTime});
}
