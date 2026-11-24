import 'package:material_ui/material_ui.dart';

import '../../../../../model/series/data/monthly/monthly_value.dart';
import '../../../../../model/series/series_def.dart';
import '../custom/custom_input.dart';
import '../input_result.dart';

class MonthlyInput extends StatelessWidget {
  const MonthlyInput({
    super.key,
    this.monthlyValue,
    required this.seriesDef,
    required this.inputMode,
  });

  final SeriesDef seriesDef;
  final MonthlyValue? monthlyValue;
  final SeriesDataInputMode inputMode;

  static Future<InputResult<MonthlyValue>?> showInputDlg(
    BuildContext context,
    SeriesDef seriesDef, {
    MonthlyValue? monthlyValue,
    required SeriesDataInputMode inputMode,
  }) async {
    return await showDialog<InputResult<MonthlyValue>>(
      context: context,
      builder: (_) => MonthlyInput(
        seriesDef: seriesDef,
        monthlyValue: monthlyValue,
        inputMode: inputMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SeriesItemsInput<MonthlyValue>(
      monthly: true,
      seriesDef: seriesDef,
      val: monthlyValue,
      inputMode: inputMode,
      resultBuilder: (uuid, dateTime, values, tagId, action) => InputResult(MonthlyValue(uuid, dateTime, values, tagId), action),
    );
  }
}
