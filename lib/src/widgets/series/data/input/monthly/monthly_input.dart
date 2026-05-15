import 'package:flutter/material.dart';

import '../../../../../model/series/data/monthly/monthly_value.dart';
import '../../../../../model/series/series_def.dart';
import '../custom/custom_input.dart';
import '../input_result.dart';

class MonthlyInput extends StatelessWidget {
  const MonthlyInput({
    super.key,
    this.monthlyValue,
    required this.seriesDef,
  });

  final SeriesDef seriesDef;
  final MonthlyValue? monthlyValue;

  static Future<InputResult<MonthlyValue>?> showInputDlg(BuildContext context, SeriesDef seriesDef, {MonthlyValue? monthlyValue}) async {
    return await showDialog<InputResult<MonthlyValue>>(
      context: context,
      builder: (_) => MonthlyInput(
        seriesDef: seriesDef,
        monthlyValue: monthlyValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SeriesItemsInput<MonthlyValue>(
      monthly: true,
      seriesDef: seriesDef,
      val: monthlyValue,
      resultBuilder: (uuid, dateTime, values, tagId, action) => InputResult(MonthlyValue(uuid, dateTime, values, tagId), action),
    );
  }
}
