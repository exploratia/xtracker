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
  static const int maxSpan = 10;

  int _maxDays = 1000;
  DateTime _firstDayStart = DateTime.now();

  RangeValues _values = RangeValues(minDays.toDouble(), maxSpan.toDouble());

  bool _isDraggingBlock = false;
  double? _lastDragDx;

  @override
  void initState() {
    widget.dateItems.sort((a, b) => a.compareTo(b));
    _firstDayStart = DateTimeUtils.truncateToDay(widget.dateItems.first);
    _maxDays = widget.dateItems.last.difference(widget.dateItems.first).inDays.abs();
    _values = RangeValues(minDays.toDouble(), min(maxSpan, _maxDays).toDouble());
    widget.pageCallback(RangeValues(_values.start.truncateToDouble(), _values.end.truncateToDouble()));
    super.initState();
  }

  void _updateValues(RangeValues rangeValues) {
    setState(() {
      // check if callback is required?
      if (_values.start.truncateToDouble() != rangeValues.start.truncateToDouble() || _values.end.truncateToDouble() != rangeValues.end.truncateToDouble()) {
        widget.pageCallback(RangeValues(_values.start.truncateToDouble(), _values.end.truncateToDouble()));
      }
      _values = rangeValues;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    if (_maxDays - minDays <= 0) {
      return Container();
    }
    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(color: themeData.colorScheme.secondary, borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                      '${DateTimeUtils.formateDate(_firstDayStart.add(Duration(days: _values.start.toInt())))} -- ${DateTimeUtils.formateDate(_firstDayStart.add(Duration(days: _values.end.toInt())))}'),
                ),
              ),
            ],
          ),
        ),
        RangeSlider(
          min: minDays.toDouble(),
          max: _maxDays.toDouble(),
          values: _values,
          divisions: (_maxDays - minDays).toInt(),
          // as we show the range always as text we need no labels here
          // labels: RangeLabels(
          //   DateTimeUtils.formateDate(_firstDayStart.add(Duration(days: _values.start.toInt()))),
          //   DateTimeUtils.formateDate(_firstDayStart.add(Duration(days: _values.end.toInt()))),
          // ),
          onChanged: (RangeValues newValues) {
            if (!_isDraggingBlock) {
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

              _updateValues(RangeValues(start, end));
            }
          },
        ),

        // drag area
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double sliderWidth = constraints.maxWidth - 48; // 48 padding
              double totalRange = (_maxDays - minDays).toDouble();

              double left = (_values.start - minDays) / totalRange * sliderWidth + 24;
              double right = (_values.end - minDays) / totalRange * sliderWidth + 24;
              double blockWidth = right - left;

              double handleWidth = 32; // blockWidth * 0.3;// limit to middle 30 %
              if (blockWidth < 64) return Container();
              double handleLeft = left + (blockWidth - handleWidth) / 2;

              return Stack(
                children: [
                  // for debug to visualize block
                  // Positioned(
                  //     left: left,
                  //     width: blockWidth,
                  //     top: 0,
                  //     bottom: 0,
                  //     child: Container(
                  //       color: Colors.green.withAlpha(128),
                  //     )),
                  // Drag handle
                  Positioned(
                    left: handleLeft,
                    width: handleWidth,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: (details) {
                        _isDraggingBlock = true;
                        _lastDragDx = details.localPosition.dx;
                      },
                      onHorizontalDragUpdate: (details) {
                        double dx = details.localPosition.dx;
                        double deltaPx = dx - (_lastDragDx ?? dx);
                        _lastDragDx = dx;

                        double deltaDays = deltaPx / sliderWidth * totalRange;

                        double newStart = _values.start + deltaDays;
                        double newEnd = _values.end + deltaDays;

                        // Clamp at min/max
                        if (newStart < minDays) {
                          newEnd += minDays - newStart;
                          newStart = minDays.toDouble();
                        }
                        if (newEnd > _maxDays) {
                          newStart -= newEnd - _maxDays;
                          newEnd = _maxDays.toDouble();
                        }

                        _updateValues(RangeValues(newStart, newEnd));
                      },
                      onHorizontalDragEnd: (_) {
                        _isDraggingBlock = false;
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: themeData.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "|||",
                            style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
