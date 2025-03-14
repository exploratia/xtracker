import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/custom_paint_utils.dart';
import '../../util/date_time_utils.dart';
import '../../util/i18n.dart';
import '../../util/theme_utils.dart';
import '../layout/single_child_scroll_view_with_scrollbar.dart';

class ResponsiveDotsView<T extends DayItem> extends StatelessWidget {
  const ResponsiveDotsView({
    super.key,
    required this.minDateTime,
    required this.maxDateTime,
    required this.data,
    required this.painterFnc,
  });

  final DateTime minDateTime;
  final DateTime maxDateTime;
  final Map<String, T> data;
  final Function(T dataItem, Canvas canvas, Offset topLeft, Offset bottomRight) painterFnc;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollViewWithScrollbar(
      child: Padding(
        padding: const EdgeInsets.only(top: ThemeUtils.seriesDataViewTopPadding),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            DateTime minDT = minDateTime;
            DateTime maxDT = maxDateTime;
            if (constraints.maxWidth > 520) {
              minDT = DateTimeUtils.firstDayOfMonth(minDT);
              maxDT = DateTimeUtils.lastDayOfMonth(maxDT);

              final dots = _DotsMonthly<T>(data: data, maxDateTime: maxDT, minDateTime: minDT, painterFnc: painterFnc);
              if (constraints.maxWidth > 1200) {
                return SizedBox(width: 1200, child: dots);
              }
              return dots;
            } else {
              if (minDT.weekday != DateTime.monday) {
                minDT = minDT.subtract(Duration(days: minDT.weekday - 1));
              }
              minDT = DateTimeUtils.truncateToDay(minDT);
              if (maxDT.weekday != DateTime.sunday) {
                maxDT = maxDT.add(Duration(days: DateTime.daysPerWeek - maxDT.weekday));
              }
              maxDT = DateTimeUtils.truncateToDay(maxDT);

              return _DotsWeekly<T>(data: data, maxDateTime: maxDT, minDateTime: minDT, painterFnc: painterFnc);
            }
          },
        ),
      ),
    );
  }
}

class DayItem {
  final DateTime dateTime;

  DayItem({required this.dateTime});
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
      size: Size(double.infinity, height),
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

class _DotsMonthly<T extends DayItem> extends StatelessWidget {
  const _DotsMonthly({
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

    const double lineHeight = 26;
    final height = (_monthDifference(minDateTime, maxDateTime) + 1 + 1) * lineHeight;

    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _DotViewPainterMonthlyRows(
          data: data,
          painterFnc: painterFnc,
          minDateTime: minDateTime,
          maxDateTime: maxDateTime,
          lineHeight: lineHeight,
          textStyle: themeData.textTheme.bodyLarge ?? const TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }

  int _monthDifference(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + (end.month - start.month);
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
    // called very often at the beginning (probably because of hiding bottom nav bar
    // final height = size.height;
    final width = size.width;
    double firstColWidth = 80;
    double colWidth = (width - firstColWidth) / 7;

    var borderColor = textStyle.color ?? Colors.grey;
    final Paint borderPaint = Paint()
      ..color = borderColor
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
    final Paint noDataPaint = Paint()..color = Colors.grey.withAlpha(64);
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
        final Rect rect = Rect.fromCenter(center: center, width: paddingX * 2, height: paddingY * 2);
        // canvas.drawRect(rect, noDataPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), noDataPaint);
      }

      // month
      if (DateTimeUtils.isMonthStart(actDate)) {
        _paintDate(actDate, topLeft.dy, lineHeight, firstColWidth, canvas);

        canvas.drawLine(topLeft.translate(0, lineHeight), topLeft.translate(0, lineHeight / 2), borderPaint);
        canvas.drawLine(topLeft.translate(0, lineHeight), bottomRight, borderPaint);
      }

      actDate = DateTimeUtils.dayBefore(actDate);
      if (actDate.weekday == DateTime.sunday) lineIdx++;
    }
  }
}

class _DotViewPainterMonthlyRows<T extends DayItem> extends _DotViewPainter<T> {
  final Function(T dataItem, Canvas canvas, Offset topLeft, Offset bottomRight) painterFnc;

  _DotViewPainterMonthlyRows({
    // super.repaint,
    required super.textStyle,
    required super.data,
    required super.minDateTime,
    required super.maxDateTime,
    required super.lineHeight,
    required this.painterFnc,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // final height = size.height;
    final width = size.width;
    double firstColWidth = 80;
    double colWidth = (width - firstColWidth) / 31;

    final Paint borderPaint = Paint()
      ..color = textStyle.color ?? Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // headline
    final TextPainter textPainter = CustomPaintUtils.textPainter();
    int idx = -1;
    for (var day in List<int>.generate(
      31,
      (index) => index + 1,
    )) {
      idx++;
      if (idx % 2 == 0 || colWidth > 30) {
        textPainter.text = TextSpan(text: '$day', style: textStyle);
        textPainter.layout();
        textPainter.paint(canvas, Offset(firstColWidth + idx * colWidth + colWidth / 2 - textPainter.width / 2, 0));
      }
    }

    // Divider
    canvas.drawLine(Offset(0, lineHeight - 6), Offset(width, lineHeight - 6), borderPaint);

    // Data
    final Paint noDataPaint = Paint()..color = Colors.grey.withAlpha(64);
    DateTime actDate = maxDateTime;
    double headerHeight = lineHeight;
    int lineIdx = 0;
    while (actDate.millisecondsSinceEpoch >= minDateTime.millisecondsSinceEpoch) {
      int colIdx = actDate.day - 1;

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
        final Rect rect = Rect.fromCenter(center: center, width: paddingX * 2, height: paddingY * 2);
        // canvas.drawRect(rect, noDataPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), noDataPaint);
      }

      // month
      if (DateTimeUtils.isMonthStart(actDate)) {
        if (actDate.month % 2 != 0) {
          _paintDate(actDate, topLeft.dy, lineHeight, firstColWidth, canvas);
        }

        // canvas.drawLine(topLeft, topLeft.translate(0, lineHeight / 2), borderPaint);
        // canvas.drawLine(topLeft, topLeft.translate(colWidth, 0), borderPaint);
      }

      if (DateTimeUtils.isMonthStart(actDate)) lineIdx++;
      actDate = DateTimeUtils.dayBefore(actDate);
    }
  }
}
