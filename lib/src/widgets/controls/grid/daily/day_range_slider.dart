import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../util/date_time_utils.dart';

class DayRangeSlider extends StatefulWidget {
  final List<DateTime> dateItems;
  final Function(RangeValues) pageCallback;

  const DayRangeSlider({super.key, required this.dateItems, required this.pageCallback});

  @override
  State<DayRangeSlider> createState() => _DayRangeSliderState();
}

class _DayRangeSliderState extends State<DayRangeSlider> {
  static const int minDays = 0;
  static const int maxSpan = 365;
  int _maxDays = 1000;
  DateTime _firstDayStart = DateTime.now();

  RangeValues _values = RangeValues(minDays.toDouble(), maxSpan.toDouble());

  @override
  void initState() {
    widget.dateItems.sort((a, b) => a.compareTo(b));
    _firstDayStart = DateTimeUtils.truncateToDay(widget.dateItems.first);
    _maxDays = widget.dateItems.last.difference(widget.dateItems.first).inDays.abs();
    _values = RangeValues(minDays.toDouble(), min(maxSpan, _maxDays).toDouble());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      min: minDays.toDouble(),
      max: _maxDays.toDouble(),
      values: _values,
      divisions: (_maxDays - minDays).toInt(),
      labels: RangeLabels(
        DateTimeUtils.formateDate(_firstDayStart.add(Duration(days: _values.start.toInt()))),
        DateTimeUtils.formateDate(_firstDayStart.add(Duration(days: _values.end.toInt()))),
      ),
      onChanged: (RangeValues newValues) {
        double start = newValues.start;
        double end = newValues.end;

        // Falls die Spanne größer als erlaubt ist → korrigieren
        if ((end - start) > maxSpan) {
          if (start != _values.start) {
            // Start wurde bewegt → Endwert anpassen
            end = start + maxSpan;
          } else {
            // End wurde bewegt → Startwert anpassen
            start = end - maxSpan;
          }
        }

        setState(() {
          _values = RangeValues(start, end);
        });
      },
    );
  }
}
