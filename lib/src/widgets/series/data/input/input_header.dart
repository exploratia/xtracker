import 'package:flutter/material.dart';

import '../../../../util/date_time_utils.dart';
import '../../../controls/select/month_switcher.dart';
import 'date_time_scrub_field.dart';

class InputHeader extends StatelessWidget {
  final DateTime dateTime;
  final Function(DateTime value) setDateTime;
  final bool monthly;

  const InputHeader({super.key, required this.dateTime, required this.setDateTime, this.monthly = false});

  DateTime get _firstDate => DateTime(2000);
  DateTime get _lastDate => DateUtils.dateOnly(DateTime.now().add(const Duration(days: 366 * 10)));

  Future<void> _selectDate(BuildContext context, DateTime dateTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: _firstDate,
      lastDate: _lastDate,
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
        DateTimeScrubField(
          value: dateTime,
          isTime: false,
          firstDate: _firstDate,
          lastDate: _lastDate,
          onChanged: setDateTime,
          onTap: () => _selectDate(context, dateTime),
          child: Text(
            DateTimeUtils.formatDate(dateTime),
            style: textStyle,
          ),
        ),
        DateTimeScrubField(
          value: dateTime,
          isTime: true,
          firstDate: _firstDate,
          lastDate: _lastDate,
          onChanged: setDateTime,
          onTap: () => _selectTime(context, dateTime),
          child: Text(
            DateTimeUtils.formatTime(dateTime),
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
