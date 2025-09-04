import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/date_time_utils.dart';
import '../../../util/defer.dart';
import '../../../util/media_query_utils.dart';
import '../../../util/theme_utils.dart';
import '../../../util/tooltip_utils.dart';
import '../animation/reverse_progress.dart';

/// ... -2 -1 0
class DayRangeSlider extends StatefulWidget {
  final DateTime date1;
  final DateTime date2;
  final int maxSpan;

  final Function(RangeValues) pageCallback;
  final Function(bool)? sliderVisibleCallback;
  final bool sliderInitialVisible;

  /// [pageCallback] receives a RangeValues
  const DayRangeSlider({
    super.key,
    required this.pageCallback,
    required this.date1,
    required this.date2,
    this.maxSpan = 366 + 31,
    this.sliderVisibleCallback,
    this.sliderInitialVisible = true,
  });

  @override
  State<DayRangeSlider> createState() => _DayRangeSliderState();

  static double calcAdditionalHeightByTextScale() {
    return MediaQueryUtils.calcAdditionalHeightByTextScale(ThemeUtils.fontSizeBodyM);
  }
}
 
class _DayRangeSliderState extends State<DayRangeSlider> {
  final _reverseProgressKey = GlobalKey<ReverseProgressState>();

  late int _maxDays;
  late DateTime _firstDayStart;
  late DateTime _lastDayStart;

  late RangeValues _values;

  bool _isDraggingBlock = false;
  double? _lastDragDx;

  late bool _sliderVisible;

  @override
  void initState() {
    _sliderVisible = widget.sliderInitialVisible;
    _calcVars();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var rangeValues = RangeValues(_values.start.roundToDouble(), _values.end.roundToDouble());
      widget.pageCallback(rangeValues);
    });
  }

  void _calcVars() {
    var dates = [widget.date1, widget.date2];
    dates.sort((a, b) => a.compareTo(b));
    _firstDayStart = DateTimeUtils.truncateToDay(dates.first);
    _lastDayStart = DateTimeUtils.truncateToDay(dates.last);
    _maxDays = DateTimeUtils.truncateToDay(dates.last).add(const Duration(hours: 12)).difference(_firstDayStart).inDays.abs();
    // start range at the end (the newest date) if maxSpan < maxDays
    _values = RangeValues(_maxDays.toDouble() - min(widget.maxSpan, _maxDays), _maxDays.toDouble());
  }

  @override
  void didUpdateWidget(covariant DayRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date1 != widget.date1 || oldWidget.date2 != widget.date2) {
      setState(() {
        _calcVars();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onProgressEnd();
      });
    }
  }

  void _toggleSliderVisible() {
    setState(() {
      _sliderVisible = !_sliderVisible;
      if (widget.sliderVisibleCallback != null) widget.sliderVisibleCallback!(_sliderVisible);
    });
  }

  void _updateValues(RangeValues rangeValues) {
    setState(() {
      // check if callback is required?
      if (_values.start.roundToDouble() != rangeValues.start.roundToDouble() || _values.end.roundToDouble() != rangeValues.end.roundToDouble()) {
        _reverseProgressKey.currentState?.restart();
      }
      _values = rangeValues;
    });
  }

  void _onProgressEnd() {
    var rangeValues = RangeValues(_values.start.roundToDouble(), _values.end.roundToDouble());
    widget.pageCallback(rangeValues);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    var initialDate = DateTimeUtils.truncateToDay(_firstDayStart.add(Duration(days: (isStartDate ? _values.start : _values.end).toInt(), hours: 12)));
    // calc min max allowed dates
    var firstDate = isStartDate ? _firstDayStart : DateTimeUtils.truncateToDay(_firstDayStart.add(Duration(days: _values.start.toInt(), hours: 12)));
    var lastDate = isStartDate ? DateTimeUtils.truncateToDay(_firstDayStart.add(Duration(days: _values.end.toInt(), hours: 12))) : _lastDayStart;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      var diff = (pickedDate.difference(_firstDayStart).inHours / 24).round().toDouble(); // hours and round instead of days because of daylight saving
      if (diff < 0) return;
      double start = (isStartDate ? diff : _values.start);
      double end = (isStartDate ? _values.end : diff);

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
  }

  @override
  Widget build(BuildContext context) {
    if (_maxDays <= 0) {
      return Container();
    }

    final themeData = Theme.of(context);
    bool isDarkMode = ThemeUtils.isDarkMode(context);
    var btnBorderColor = isDarkMode ? Colors.white12 : Colors.black12;
    var btnBoxDecoration = BoxDecoration(
      color: themeData.scaffoldBackgroundColor.withAlpha(192),
      border: Border.all(color: btnBorderColor, width: 1),
      borderRadius: BorderRadius.circular(ThemeUtils.borderRadiusLarge),
    );
    var btnTextStyle = TooltipUtils.tooltipMonospaceStyle.copyWith(color: themeData.colorScheme.primary);

    return Stack(
      children: [
        // progress
        Positioned(
          left: ThemeUtils.screenPadding,
          right: ThemeUtils.screenPadding,
          top: 54,
          height: 1 * MediaQueryUtils.textScaleFactor,
          child: ReverseProgress(
            key: _reverseProgressKey,
            maxWidth: 230,
            height: 1 * MediaQueryUtils.textScaleFactor,
            color: themeData.colorScheme.secondary,
            duration: Defer.defaultDuration,
            onEndCallback: _onProgressEnd,
          ),
        ),
        // button with date range
        Positioned(
          left: 0,
          right: 0,
          top: 2,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth, // extend if row smaller then layout builder width
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: ThemeUtils.horizontalSpacing,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: btnBoxDecoration,
                        child: Row(
                          children: [
                            Tooltip(
                              message: LocaleKeys.commons_btn_selectDate_tooltip.tr(),
                              child: TextButton(
                                onPressed: () => _selectDate(context, true),
                                child: Text(
                                  DateTimeUtils.formateYYYMMDD(_firstDayStart.add(Duration(days: _values.start.toInt(), hours: 12))),
                                  style: btnTextStyle,
                                ),
                              ),
                            ),
                            Text(
                              "-",
                              style: btnTextStyle,
                            ),
                            Tooltip(
                              message: LocaleKeys.commons_btn_selectDate_tooltip.tr(),
                              child: TextButton(
                                onPressed: () => _selectDate(context, false),
                                child: Text(
                                  DateTimeUtils.formateYYYMMDD(_firstDayStart.add(Duration(days: _values.end.toInt(), hours: 12))),
                                  style: btnTextStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: btnBoxDecoration,
                        child: Tooltip(
                          message: _sliderVisible
                              ? LocaleKeys.controls_select_dayRangeSlider_btn_hideSlider.tr()
                              : LocaleKeys.controls_select_dayRangeSlider_btn_showSlider.tr(),
                          child: TextButton(
                            // button a bit smaller width to not overflow at 250
                            style: TextButton.styleFrom(
                              minimumSize: const Size(56, 48),
                            ),
                            onPressed: _toggleSliderVisible,
                            child: Text(
                              _sliderVisible ? '▼' : '▲',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Slider
        Positioned(
          left: 0,
          right: 0,
          bottom: 2,
          height: 48,
          child: IgnorePointer(
            ignoring: !_sliderVisible,
            child: AnimatedOpacity(
              opacity: _sliderVisible ? 1 : 0,
              duration: Duration(milliseconds: _sliderVisible ? ThemeUtils.animationDuration : ThemeUtils.animationDurationShort),
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
          ),
        ),

        // drag area (only if slider is not on min & max)
        if (_values.start > 0 || _values.end < _maxDays)
          Positioned(
            left: 0,
            right: 0,
            bottom: 2,
            height: 48,
            child: IgnorePointer(
              ignoring: !_sliderVisible,
              child: AnimatedOpacity(
                opacity: _sliderVisible ? 1 : 0,
                duration: Duration(milliseconds: _sliderVisible ? ThemeUtils.animationDuration : ThemeUtils.animationDurationShort),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double sliderWidth = constraints.maxWidth - 48; // 48 padding
                    double totalRange = _maxDays.toDouble();

                    double left = _values.start / totalRange * sliderWidth + 24;
                    double right = _values.end / totalRange * sliderWidth + 24;
                    double blockWidth = right - left;

                    double handleWidth = 32; // blockWidth * 0.3;// limit to middle 30 %

                    // calc handle position
                    // if space between slider handles is to small go to left/right depending on position
                    // otherwise draw drag handle in the middle
                    double handleLeft = 0;
                    if (blockWidth < 64) {
                      var middle = sliderWidth / 2 + 24;
                      if (left > middle) {
                        handleLeft = left - handleWidth * 2;
                      } else {
                        handleLeft = right + handleWidth;
                      }
                    } else {
                      handleLeft = left + (blockWidth - handleWidth) / 2;
                    }

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
                                borderRadius: ThemeUtils.borderRadiusCircular,
                              ),
                              child: const Center(
                                  child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: ThemeUtils.horizontalSpacingSmall,
                                children: [
                                  _DragLine(),
                                  _DragLine(),
                                  _DragLine(),
                                ],
                              )),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DragLine extends StatelessWidget {
  const _DragLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtils.onPrimary,
      height: ThemeUtils.fontSizeBodyM,
      width: 2,
    );
  }
}
