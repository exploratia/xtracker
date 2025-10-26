import 'package:flutter/material.dart';

import '../../../../util/date_time_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/select/month_switcher.dart';

class InputHeader extends StatelessWidget {
  final DateTime dateTime;
  final Function(DateTime value) setDateTime;
  final bool monthly;

  const InputHeader({super.key, required this.dateTime, required this.setDateTime, this.monthly = false});

  Future<void> _selectDate(BuildContext context, DateTime dateTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 366 * 10)),
    );

    if (pickedDate != null) setDateTime(pickedDate.copyWith(hour: dateTime.hour, minute: dateTime.minute));
  }

  Future<void> _selectTime(BuildContext context, DateTime dateTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dateTime),
    );

    if (pickedTime != null) setDateTime(dateTime.copyWith(hour: pickedTime.hour, minute: pickedTime.minute));
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var textStyle = themeData.textTheme.titleMedium;

    if (monthly) {
      return MonthSwitcher(
        initialDate: dateTime,
        monthCallback: setDateTime,
      );
    }

    textStyle = textStyle?.copyWith(color: themeData.colorScheme.primary);
    return Wrap(
      runAlignment: WrapAlignment.center,
      spacing: 20,
      children: [
        InkWell(
          borderRadius: ThemeUtils.borderRadiusCircularSmall,
          onTap: () => _selectDate(context, dateTime),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              DateTimeUtils.formatDate(dateTime),
              style: textStyle,
            ),
          ),
        ),
        InkWell(
          borderRadius: ThemeUtils.borderRadiusCircularSmall,
          onTap: () => _selectTime(context, dateTime),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              DateTimeUtils.formatTime(dateTime),
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }
}
