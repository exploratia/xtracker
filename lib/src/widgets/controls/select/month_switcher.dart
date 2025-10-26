import 'package:flutter/material.dart';

import '../../../util/date_time_utils.dart';
import '../../../util/theme_utils.dart';

class MonthSwitcher extends StatefulWidget {
  const MonthSwitcher({super.key, this.initialDate, required this.monthCallback});

  final DateTime? initialDate;
  final Function(DateTime month) monthCallback;

  @override
  State<MonthSwitcher> createState() => _MonthSwitcherState();
}

class _MonthSwitcherState extends State<MonthSwitcher> {
  late DateTime _currentDate;

  bool _isForward = true; // true: next month, false: prev month
  late Widget _animatedWidget;

  @override
  void initState() {
    _currentDate = widget.initialDate ?? DateTime.now();
    var curDateStr = DateTimeUtils.formatMonthYear(_currentDate);
    _animatedWidget = Text(
      curDateStr,
      key: Key(curDateStr),
      textAlign: TextAlign.center,
    );
    super.initState();
  }

  void _changeMonth(int delta) {
    setState(() {
      _isForward = delta > 0;
      _currentDate = DateTime(_currentDate.year, _currentDate.month + delta);
      widget.monthCallback(_currentDate);
      var curDateStr = DateTimeUtils.formatMonthYear(_currentDate);
      _animatedWidget = Text(
        curDateStr,
        key: Key(curDateStr),
        textAlign: TextAlign.center,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var offset1 = Tween(begin: Offset(_isForward ? 1 : -1, 0), end: const Offset(0, 0));
    var offset2 = Tween(begin: Offset(_isForward ? -1 : 1, 0), end: const Offset(0, 0));
    var opacity1 = Tween<double>(begin: 0, end: 1);
    var opacity2 = Tween<double>(begin: 0, end: 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          color: ThemeUtils.primaryColor,
          onPressed: () => _changeMonth(-1),
        ),
        SizedBox(
          width: 160,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => SlideTransition(
              position: (animation.value == 1 ? offset1 : offset2).animate(animation),
              child: FadeTransition(
                opacity: (animation.value == 1 ? opacity1 : opacity2).animate(animation),
                child: child,
              ),
            ),
            child: _animatedWidget,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: ThemeUtils.primaryColor,
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }
}
