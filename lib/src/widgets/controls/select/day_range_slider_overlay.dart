import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';
import 'day_range_slider.dart';

class DayRangeSliderOverlay extends StatefulWidget {
  const DayRangeSliderOverlay({super.key, required this.maxSpan, required this.date1, required this.date2, required this.setFilter});

  final int maxSpan;
  final DateTime date1;
  final DateTime date2;
  final Function(RangeValues daysRange) setFilter;

  @override
  State<DayRangeSliderOverlay> createState() => _DayRangeSliderOverlayState();
}

class _DayRangeSliderOverlayState extends State<DayRangeSliderOverlay> {
  bool _sliderVisible = false;

  void _setSliderVisible(bool visible) {
    setState(() {
      _sliderVisible = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    double addHeightForTextScale = DayRangeSlider.calcAdditionalHeightByTextScale();

    return Stack(
      children: [
        // filter view background - extra widget to be able to use ignore pointer
        AnimatedPositioned(
          height: ThemeUtils.seriesDataBottomFilterViewHeight + addHeightForTextScale + (_sliderVisible ? 48 : 0),
          left: 0,
          right: 0,
          bottom: 0,
          duration: const Duration(milliseconds: ThemeUtils.animationDuration),
          child: IgnorePointer(
            child: Container(
              color: themeData.scaffoldBackgroundColor.withAlpha(128),
            ),
          ),
        ),
        AnimatedPositioned(
          height: ThemeUtils.seriesDataBottomFilterViewHeight + addHeightForTextScale + (_sliderVisible ? 48 : 0),
          left: 0,
          right: 0,
          bottom: 0,
          duration: const Duration(milliseconds: ThemeUtils.animationDuration),
          child: DayRangeSlider(
              pageCallback: widget.setFilter,
              maxSpan: widget.maxSpan,
              sliderInitialVisible: false,
              sliderVisibleCallback: _setSliderVisible,
              date1: widget.date1,
              date2: widget.date2),
        ),
      ],
    );
  }
}
