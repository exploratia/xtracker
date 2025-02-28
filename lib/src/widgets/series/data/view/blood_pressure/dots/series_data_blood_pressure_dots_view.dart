import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/custom_paint_utils.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/i18n.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../layout/single_child_scroll_view_with_scrollbar.dart';

class SeriesDataBloodPressureDotsView extends StatelessWidget {
  const SeriesDataBloodPressureDotsView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesViewMetaData seriesViewMetaData;
  final SeriesData<BloodPressureValue> seriesData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollViewWithScrollbar(
      child: Padding(
        padding: const EdgeInsets.only(top: ThemeUtils.seriesDataViewTopPadding),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            Map<String, _BloodPressureDayItem> data = _buildDataProvider(seriesData);
            DateTime minDateTime = DateTime.now();
            DateTime maxDateTime = DateTime.now();
            if (seriesData.seriesItems.isNotEmpty) {
              minDateTime = seriesData.seriesItems.first.dateTime;
              maxDateTime = seriesData.seriesItems.last.dateTime;
            }

            painterFnc(_BloodPressureDayItem dataItem, Canvas canvas, Offset topLeft, Offset bottomRight) {
              List<Color> colors = [BloodPressureValue.colorHigh(dataItem.high), BloodPressureValue.colorLow(dataItem.low)];
              final rect = Rect.fromPoints(topLeft, bottomRight);
              CustomPaintUtils.paintGradientFilledRect(canvas, rect, colors, const Alignment(0, 1), const Alignment(0, -1));
            }

            if (constraints.maxWidth > 500) {
              if (minDateTime.weekday != DateTime.monday) {
                minDateTime = minDateTime.subtract(Duration(days: minDateTime.weekday - 1));
              }
              if (maxDateTime.weekday != DateTime.sunday) {
                maxDateTime = maxDateTime.add(Duration(days: DateTime.daysPerWeek - maxDateTime.weekday));
              }
              return _DotsWeekly<_BloodPressureDayItem>(data: data, maxDateTime: maxDateTime, minDateTime: minDateTime, painterFnc: painterFnc);
            } else {
              minDateTime = DateTimeUtils.firstDayOfMonth(minDateTime);
              maxDateTime = DateTimeUtils.lastDayOfMonth(maxDateTime);

              return _DotsWeekly<_BloodPressureDayItem>(data: data, maxDateTime: maxDateTime, minDateTime: minDateTime, painterFnc: painterFnc);
            }
          },
        ),
      ),
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

class DayItem {
  final DateTime dateTime;

  DayItem({required this.dateTime});
}

class _BloodPressureDayItem extends DayItem {
  int high = -1000;
  int low = 1000;

  _BloodPressureDayItem({required super.dateTime});

  updateHighLow(int valH, int valL) {
    high = max(high, valH);
    low = min(low, valL);
  }
}

class _DotsWeekly<T extends DayItem> extends StatelessWidget {
  const _DotsWeekly({
    required this.data,
    required this.painterFnc,
    required this.minDateTime,
    required this.maxDateTime,
  });

  final Map<String, T> data;
  final Function(T dataItem, Canvas canvas, Offset topLeft, Offset bottomRight) painterFnc;

  final DateTime minDateTime;
  final DateTime maxDateTime;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final List<String> shortWeekDays = I18N.composeShortWeekdays(t);

    const double lineHeight = 26;
    final height = ((maxDateTime.difference(minDateTime).inDays + 1) / 7 + 1) * lineHeight;

    return CustomPaint(
      size: Size(double.infinity, height), // todo center h
      painter: _DotViewPainterWeeklyRows(
          data: data,
          painterFnc: painterFnc,
          minDateTime: minDateTime,
          maxDateTime: maxDateTime,
          shortWeekDays: shortWeekDays,
          lineHeight: lineHeight,
          textStyle: themeData.textTheme.bodyLarge ?? const TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }
}

abstract class _DotViewPainter<T extends DayItem> extends CustomPainter {
  final TextStyle textStyle;
  final Map<String, T> data;
  final DateTime minDateTime;
  final DateTime maxDateTime;
  final double lineHeight;

  _DotViewPainter({super.repaint, required this.textStyle, required this.data, required this.minDateTime, required this.maxDateTime, required this.lineHeight});

  void _paintDate(DateTime dateTime, double yPos, double lineHeight, double firstColWidth, Canvas canvas) {
    final TextPainter textPainter = CustomPaintUtils.textPainter();
    String dateString = DateTimeUtils.formateMMMYYYY(dateTime);
    textPainter.text = TextSpan(text: dateString, style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(firstColWidth - 10 - textPainter.width, yPos + lineHeight / 2 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _DotViewPainterWeeklyRows<T extends DayItem> extends _DotViewPainter<T> {
  final List<String> shortWeekDays;
  final Function(T dataItem, Canvas canvas, Offset topLeft, Offset bottomRight) painterFnc;

  _DotViewPainterWeeklyRows(
      { // super.repaint,
      required super.textStyle,
      required super.data,
      required super.minDateTime,
      required super.maxDateTime,
      required super.lineHeight,
      required this.painterFnc,
      required this.shortWeekDays});

  @override
  void paint(Canvas canvas, Size size) {
    // final height = size.height;
    final width = size.width;
    double firstColWidth = 80;
    double colWidth = (width - firstColWidth) / 7;

    final Paint borderPaint = Paint()
      ..color = textStyle.color ?? Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // headline
    final TextPainter textPainter = CustomPaintUtils.textPainter();
    int idx = -1;
    for (var shortWeekDay in shortWeekDays) {
      idx++;
      textPainter.text = TextSpan(text: shortWeekDay, style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(firstColWidth + idx * colWidth + colWidth / 2 - textPainter.width / 2, 0));
    }

    // Divider
    canvas.drawLine(Offset(0, lineHeight - 6), Offset(width, lineHeight - 6), borderPaint);

    // Data
    DateTime actDate = maxDateTime;
    double headerHeight = lineHeight;
    int lineIdx = 0;
    while (actDate.millisecondsSinceEpoch >= minDateTime.millisecondsSinceEpoch) {
      int colIdx = actDate.weekday - 1;

      final topLeft = Offset(firstColWidth + colIdx * colWidth, headerHeight + lineHeight * lineIdx);
      final bottomRight = Offset(firstColWidth + colIdx * colWidth + colWidth, headerHeight + lineHeight * lineIdx + lineHeight);
      final center = Offset(topLeft.dx + colWidth / 2, topLeft.dy + lineHeight / 2);

      var backgroundColor = DateTimeUtils.backgroundColor(actDate);
      if (backgroundColor != null) {
        final Paint rectPaint = Paint()..color = backgroundColor;
        final Rect rect = Rect.fromPoints(topLeft, bottomRight);
        canvas.drawRect(rect, rectPaint);
      }

      double paddingX = min(5, colWidth / 2);
      double paddingY = min(5, lineHeight / 2);

      T? dataItem = data[DateTimeUtils.formateDate(actDate)];
      if (dataItem != null) {
        final tl = Offset(center.dx - paddingX, center.dy - paddingY);
        final br = Offset(center.dx + paddingX, center.dy + paddingY);
        painterFnc(dataItem, canvas, tl, br);
      } else {
        final Paint rectPaint = Paint()..color = Colors.grey.withAlpha(64);
        final Rect rect = Rect.fromCenter(center: center, width: paddingX * 2, height: paddingY * 2);
        canvas.drawRect(rect, rectPaint);
      }

      // month
      if (DateTimeUtils.isMonthStart(actDate)) {
        _paintDate(actDate, topLeft.dy, lineHeight, firstColWidth, canvas);

        canvas.drawLine(topLeft, topLeft.translate(0, lineHeight / 2), borderPaint);
        canvas.drawLine(topLeft, topLeft.translate(colWidth, 0), borderPaint);
      }

      actDate = actDate.subtract(const Duration(days: 1));
      if (actDate.weekday == DateTime.sunday) lineIdx++;
    }
  }
}
