import 'package:flutter/material.dart';

import '../../../../model/series/series_def.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/theme_utils.dart';

class InputHeader extends StatelessWidget {
  final DateTime dateTime;
  final SeriesDef seriesDef;
  final Function(DateTime value) setDateTime;

  const InputHeader({super.key, required this.dateTime, required this.seriesDef, required this.setDateTime});

  @override
  Widget build(BuildContext context) {
    return _DateTimeHeader(dateTime: dateTime, setDateTime: setDateTime);
  }
}

class _DateTimeHeader extends StatelessWidget {
  const _DateTimeHeader({
    required this.dateTime,
    required this.setDateTime,
  });

  final DateTime dateTime;
  final Function(DateTime value) setDateTime;

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
              DateTimeUtils.formateDate(dateTime),
              style: TextStyle(inherit: true, color: themeData.colorScheme.primary),
            ),
          ),
        ),
        InkWell(
          borderRadius: ThemeUtils.borderRadiusCircularSmall,
          onTap: () => _selectTime(context, dateTime),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              DateTimeUtils.formateTime(dateTime),
              style: TextStyle(inherit: true, color: themeData.colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
