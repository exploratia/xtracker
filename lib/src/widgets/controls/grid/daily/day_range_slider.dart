import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../util/date_time_utils.dart';
import '../../../../util/defer.dart';
import '../../../../util/tooltip_utils.dart';
import '../../animation/reverse_progress.dart';

/// ... -2 -1 0
class DayRangeSlider extends StatefulWidget {
  final DateTime date1;
  final DateTime date2;
  final int maxSpan;

  final Function(RangeValues) pageCallback;

  /// [pageCallback] receives a RangeValues
  const DayRangeSlider({super.key, required this.pageCallback, required this.date1, required this.date2, this.maxSpan = 366 + 31});

  @override
  State<DayRangeSlider> createState() => _DayRangeSliderState();
}

class _DayRangeSliderState extends State<DayRangeSlider> {
  final _reverseProgressKey = GlobalKey<ReverseProgressState>();

  late int _maxDays;
  late DateTime _firstDayStart;

  late RangeValues _values;

  bool _isDraggingBlock = false;
  double? _lastDragDx;

  Defer defer = Defer();

  @override
  void initState() {
    var dates = [widget.date1, widget.date2];
    dates.sort((a, b) => a.compareTo(b));
    _firstDayStart = DateTimeUtils.truncateToDay(dates.first);
    _maxDays = dates.last.difference(dates.first).inDays.abs();
    // start range at the end (the newest date) if maxSpan < maxDays
    _values = RangeValues(_maxDays.toDouble() - min(widget.maxSpan, _maxDays), _maxDays.toDouble());
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => widget.pageCallback(RangeValues(_values.start.truncateToDouble(), _values.end.truncateToDouble())));
  }

  @override
  void dispose() {
    defer.cancel();
    super.dispose();
  }

  void _updateValues(RangeValues rangeValues) {
    setState(() {
      // check if callback is required?
      if (_values.start.roundToDouble() != rangeValues.start.roundToDouble() || _values.end.roundToDouble() != rangeValues.end.roundToDouble()) {
        _reverseProgressKey.currentState?.restart();
        // defer.call(() => widget.pageCallback(RangeValues(rangeValues.start.roundToDouble(), rangeValues.end.roundToDouble())));
      }
      _values = rangeValues;
    });
  }

  void _onProgressEnd() {
    widget.pageCallback(RangeValues(_values.start.roundToDouble(), _values.end.roundToDouble()));
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    if (_maxDays <= 0) {
      return Container();
    }

    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          Positioned(
            left: 24,
            right: 0,
            top: 10,
            height: 1,
            child: ReverseProgress(
              key: _reverseProgressKey,
              maxWidth: 50,
              height: 1,
              color: themeData.colorScheme.secondary,
              duration: Defer.defaultDuration,
              onEndCallback: _onProgressEnd,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 1,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    // color: themeData.colorScheme.secondary,
                    border: Border.all(color: themeData.colorScheme.secondary, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 1),
                    child: Text(
                      '${DateTimeUtils.formateYYYMMDD(_firstDayStart.add(Duration(days: _values.start.toInt())))} -- ${DateTimeUtils.formateYYYMMDD(_firstDayStart.add(Duration(days: _values.end.toInt())))}',
                      style: TooltipUtils.tooltipMonospaceStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 48,
            child: RangeSlider(
              min: 0,
              max: _maxDays.toDouble(),
              values: _values,
              divisions: _maxDays,
              // as we show the range always as text we need no labels here
              // labels: RangeLabels(
              //   DateTimeUtils.formateDate(_firstDayStart.add(Duration(days: _values.start.toInt()))),
              //   DateTimeUtils.formateDate(_firstDayStart.add(Duration(days: _values.end.toInt()))),
              // ),
              onChanged: (RangeValues newValues) {
                if (!_isDraggingBlock) {
                  double start = newValues.start;
                  double end = newValues.end;

                  //correct if span > maxSpan
                  if ((end - start) > widget.maxSpan) {
                    if (start != _values.start) {
                      end = start + widget.maxSpan; // Start was moved → adjust end
                    } else {
                      start = end - widget.maxSpan; // End was moved → adjust start
                    }
                  }

                  _updateValues(RangeValues(start, end));
                }
              },
            ),
          ),

          // drag area
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 48,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double sliderWidth = constraints.maxWidth - 48; // 48 padding
                double totalRange = _maxDays.toDouble();

                double left = _values.start / totalRange * sliderWidth + 24;
                double right = _values.end / totalRange * sliderWidth + 24;
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
                          if (newStart < 0) {
                            newEnd += -newStart;
                            newStart = 0;
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
      ),
    );
  }
}
