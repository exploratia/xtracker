import 'package:flutter/material.dart';

import '../../../../../model/series/data/monthly/monthly_value.dart';
import '../../../../../model/series/series_def.dart';
import '../free/multi_value_input.dart';
import '../input_result.dart';

class MonthlyInput extends MultiValueInput<MonthlyValue> {
  const MonthlyInput({super.key, required super.seriesDef, super.multiValue, required super.valueBuilder});

  static Future<InputResult<MonthlyValue>?> showInputDlg(BuildContext context, SeriesDef seriesDef, {MonthlyValue? monthlyValue}) async {
    return await showDialog<InputResult<MonthlyValue>>(
      context: context,
      builder: (_) => MonthlyInput(
        seriesDef: seriesDef,
        multiValue: monthlyValue,
        valueBuilder: (String uuid, DateTime dateTime, Map<String, double> values) => MonthlyValue(uuid, dateTime, values),
      ),
    );
  }
}
