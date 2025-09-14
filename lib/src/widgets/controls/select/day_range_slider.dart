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
import '../layout/h_centered_scroll_view.dart';

class DayRangeSlider extends StatefulWidget {
  final DateTime _dateRangeFrom;
  final DateTime _dateRangeTill;
  final int maxSpan;
  final DateTime? _selectedDateRangeFrom;
  final DateTime? _selectedDateRangeTill;

  final Function(DayRange) rangeCallback;
  final Function(bool)? sliderVisibleCallback;
  final bool sliderInitialVisible;

  /// For all dateTimes only the day part is used
  ///
  /// - [rangeCallback] receives a DayRange (till is EndOfDay)
  DayRangeSlider({
    super.key,
    required DateTime dateRangeFrom,
    required DateTime dateRangeTill,
    DateTime? selectedDateRangeFrom,
    DateTime? selectedDateRangeTill,
    required this.rangeCallback,
    this.sliderVisibleCallback,
    this.maxSpan = 366 + 31,
    this.sliderInitialVisible = true,
  })  : _dateRangeFrom = DateTimeUtils.truncateToDay(dateRangeFrom),
        _dateRangeTill = DateTimeUtils.truncateToDay(dateRangeTill),
        _selectedDateRangeFrom = selectedDateRangeFrom != null ? DateTimeUtils.truncateToDay(selectedDateRangeFrom) : null,
        _selectedDateRangeTill = selectedDateRangeTill != null ? DateTimeUtils.truncateToDay(selectedDateRangeTill) : null;

  @override
  State<DayRangeSlider> createState() => _DayRangeSliderState();

  static double calcAdditionalHeightByTextScale() {
    return MediaQueryUtils.calcAdditionalHeightByTextScale(ThemeUtils.fontSizeBodyM);
  }
}

class _DayRangeSliderState extends State<DayRangeSlider> {
  final _reverseProgressKey = GlobalKey<ReverseProgressState>();

  late DateTime _dateRangeFrom;
  late DateTime _dateRangeTill;

  // slider values from 0 to _sliderRange = max days possible
  late int _sliderRange;

  late RangeValues _values;

  bool _isDraggingBlock = false;
  double? _lastDragDx;

  late bool _sliderVisible;

  @override
  void initState() {
    _sliderVisible = widget.sliderInitialVisible;
    _initVars();

    // selected range given?
    if (widget._selectedDateRangeFrom != null) {
      DayRange selectedDayRange = DayRange(
        widget._selectedDateRangeFrom!,
        // if no till filter is set use today or future date if there is already a series data value
        widget._selectedDateRangeTill ?? DateTimeUtils.truncateToDay(DateTimeUtils.maxDate(widget._dateRangeTill, DateTime.now())),
      );
      _setValuesFromDayRange(selectedDayRange);
    }
    // otherwise start range at the end (the newest date) if maxSpan < maxDays
    else {
      _values = RangeValues(_sliderRange.toDouble() - min(widget.maxSpan, _sliderRange), _sliderRange.toDouble());
    }

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onProgressEnd();
    });
  }

  void _setValuesFromDayRange(DayRange dayRange) {
    DateTime from = dayRange.from;
    DateTime till = dayRange.till;
    // check range
    if (from.isBefore(_dateRangeFrom) || from.isAfter(_dateRangeTill)) {
      from = _dateRangeFrom;
    }
    if (till.isAfter(_dateRangeTill) || till.isBefore(_dateRangeFrom)) {
      till = _dateRangeTill;
    }
    // build difference to midday to ensure all full days are included (because of daylight saving)
    _values = RangeValues(_dateRangeFrom.difference(DateTimeUtils.truncateToMidDay(from)).inDays.abs().toDouble(),
        _dateRangeFrom.difference(DateTimeUtils.truncateToMidDay(till)).inDays.abs().toDouble());
  }

  void _initVars() {
    // Widget dates are already truncated
    _dateRangeFrom = widget._dateRangeFrom;
    _dateRangeTill = widget._dateRangeTill;
    _sliderRange = _dateRangeTill.add(const Duration(hours: 12)).difference(_dateRangeFrom).inDays.abs();
  }

  @override
  void didUpdateWidget(covariant DayRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._dateRangeFrom != widget._dateRangeFrom || oldWidget._dateRangeTill != widget._dateRangeTill || oldWidget.maxSpan != widget.maxSpan) {
      setState(() {
        // save act dates to be able to restore
        var actSelectedValues = _buildDayRange(false);
        _initVars();
        // restore dates
        _setValuesFromDayRange(actSelectedValues);
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
    DayRange dayRange = _buildDayRange(true);
    widget.rangeCallback(dayRange);
  }

  DayRange _buildDayRange(bool forExternals) {
    DayRange dayRange = DayRange(
      DateTimeUtils.truncateToDay(_dateRangeFrom.add(Duration(days: _values.start.roundToDouble().toInt(), hours: 12))),
      DateTimeUtils.endOfDay(_dateRangeFrom.add(Duration(days: _values.end.roundToDouble().toInt(), hours: 12))),
    );
    return dayRange;
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    var initialDate = DateTimeUtils.truncateToDay(_dateRangeFrom.add(Duration(days: (isStartDate ? _values.start : _values.end).toInt(), hours: 12)));
    // calc min max allowed dates
    var firstDate = isStartDate ? _dateRangeFrom : DateTimeUtils.truncateToDay(_dateRangeFrom.add(Duration(days: _values.start.toInt(), hours: 12)));
    var lastDate = isStartDate ? DateTimeUtils.truncateToDay(_dateRangeFrom.add(Duration(days: _values.end.toInt(), hours: 12))) : _dateRangeTill;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      var diff = (pickedDate.difference(_dateRangeFrom).inHours / 24).round().toDouble(); // hours and round instead of days because of daylight saving
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
    if (_sliderRange <= 0) {
      return const Center(child: Text("Not enough data..."));
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
          child: HCenteredScrollView(
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
                          DateTimeUtils.formatYYYYMMDD(_dateRangeFrom.add(Duration(days: _values.start.toInt(), hours: 12))),
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
                          DateTimeUtils.formatYYYYMMDD(_dateRangeFrom.add(Duration(days: _values.end.toInt(), hours: 12))),
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
                max: _sliderRange.toDouble(),
                values: _values,
                divisions: _sliderRange,
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
        if (_values.start > 0 || _values.end < _sliderRange)
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
                    double totalRange = _sliderRange.toDouble();

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
                              if (newEnd > _sliderRange) {
                                newStart -= newEnd - _sliderRange;
                                newEnd = _sliderRange.toDouble();
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

class DayRange {
  final DateTime from;
  final DateTime till;

  DayRange(this.from, this.till);

  @override
  String toString() {
    return 'DayRange{from: ${DateTimeUtils.formatYYYYMMDD(from)}, till: ${DateTimeUtils.formatYYYYMMDD(till)}}';
  }
}
