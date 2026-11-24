import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/date_time_utils.dart';
import '../../../util/theme_utils.dart';
import '../../../util/motion_utils.dart';

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

  Future<void> _selectMonth(BuildContext context, DateTime dateTime) async {
    final themeData = Theme.of(context);
    final DateTime? pickedDate = await showMonthPicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 366 * 10)),
      headerTitle: Text(LocaleKeys.controls_select_monthSwitcher_label_selectMonth.tr()),
      monthPickerDialogSettings: MonthPickerDialogSettings(
        headerSettings: PickerHeaderSettings(
          headerIconsColor: ThemeUtils.onPrimary,
          headerPadding: const EdgeInsets.all(ThemeUtils.defaultPadding),
          titleSpacing: ThemeUtils.verticalSpacing,
          headerBackgroundColor: themeData.cardTheme.color,
        ),
        dialogSettings: PickerDialogSettings(
          dialogBackgroundColor: themeData.badgeTheme.backgroundColor,
          dismissible: true,
          dialogRoundedCornersRadius: ThemeUtils.borderRadiusLarge,
        ),
        dateButtonsSettings: const PickerDateButtonsSettings(
          currentMonthTextColor: ThemeUtils.primaryColor,
          currentYearTextColor: ThemeUtils.primaryColor,
          selectedDateRadius: 10,
          selectedMonthTextColor: ThemeUtils.onPrimary,
          selectedYearTextColor: ThemeUtils.onPrimary,
          selectedMonthBackgroundColor: ThemeUtils.primaryColor,
          unselectedMonthsTextColor: ThemeUtils.onPrimary,
          unselectedYearsTextColor: ThemeUtils.onPrimary,
        ),
        actionBarSettings: const PickerActionBarSettings(
          actionBarPadding: EdgeInsets.all(ThemeUtils.screenPadding),
        ),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        _currentDate = pickedDate.copyWith(hour: dateTime.hour, minute: dateTime.minute);
        widget.monthCallback(_currentDate);
        var curDateStr = DateTimeUtils.formatMonthYear(_currentDate);
        _animatedWidget = InkWell(
          key: Key(curDateStr),
          borderRadius: ThemeUtils.borderRadiusCircularSmall,
          onTap: () => _selectMonth(context, _currentDate),
          child: Text(
            curDateStr,
          ),
        );
      });
    }
  }

  @override
  void initState() {
    _currentDate = widget.initialDate ?? DateTime.now();
    var curDateStr = DateTimeUtils.formatMonthYear(_currentDate);
    _animatedWidget = InkWell(
      key: Key(curDateStr),
      borderRadius: ThemeUtils.borderRadiusCircularSmall,
      onTap: () => _selectMonth(context, _currentDate),
      child: Text(
        curDateStr,
      ),
    );
    super.initState();
  }

  void _changeMonth(int delta) {
    setState(() {
      _isForward = delta > 0;
      _currentDate = DateTime(_currentDate.year, _currentDate.month + delta);
      widget.monthCallback(_currentDate);
      var curDateStr = DateTimeUtils.formatMonthYear(_currentDate);
      _animatedWidget = InkWell(
        key: Key(curDateStr),
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
        onTap: () => _selectMonth(context, _currentDate),
        child: Text(
          curDateStr,
        ),
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
            duration: MotionUtils.resolve(context, MotionUtils.emphasized),
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
