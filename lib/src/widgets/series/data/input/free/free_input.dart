import 'package:flutter/material.dart';

import '../../../../../model/series/data/free/free_value.dart';
import '../../../../../model/series/series_def.dart';
import '../input_result.dart';
import 'multi_value_input.dart';

class FreeInput extends MultiValueInput<FreeValue> {
  const FreeInput({super.key, required super.seriesDef, super.multiValue, required super.valueBuilder});

  static Future<InputResult<FreeValue>?> showInputDlg(BuildContext context, SeriesDef seriesDef, {FreeValue? freeValue}) async {
    return await showDialog<InputResult<FreeValue>>(
      context: context,
      builder: (_) => FreeInput(
        seriesDef: seriesDef,
        multiValue: freeValue,
        valueBuilder: (String uuid, DateTime dateTime, Map<String, double> values) => FreeValue(uuid, dateTime, values),
      ),
    );
  }
}
