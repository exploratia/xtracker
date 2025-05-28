import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../providers/series_current_value_provider.dart';
import '../../../../util/date_time_utils.dart';
import 'blood_pressure/table/blood_pressure_value_renderer.dart';
import 'daily_check/table/daily_check_value_renderer.dart';

class SeriesLatestValueRenderer extends StatelessWidget {
  const SeriesLatestValueRenderer({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        {
          var bloodPressureValue = context.read<SeriesCurrentValueProvider>().bloodPressureCurrentValue(seriesDef);
          if (bloodPressureValue != null) {
            return Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(DateTimeUtils.formateDate(bloodPressureValue.dateTime)),
                Text(DateTimeUtils.formateTime(bloodPressureValue.dateTime)),
                BloodPressureValueRenderer(bloodPressureValue: bloodPressureValue, seriesDef: seriesDef),
              ],
            );
          }
          return Center(child: Text(LocaleKeys.series_data_noData.tr()));
        }
      case SeriesType.dailyCheck:
        {
          var currentValue = context.read<SeriesCurrentValueProvider>().dailyCheckCurrentValue(seriesDef);
          if (currentValue != null) {
            return Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(DateTimeUtils.formateDate(currentValue.dateTime)),
                Text(DateTimeUtils.formateTime(currentValue.dateTime)),
                DailyCheckValueRenderer(dailyCheckValue: currentValue, seriesDef: seriesDef),
              ],
            );
          }
          return Center(child: Text(LocaleKeys.series_data_noData.tr()));
        }
      case SeriesType.monthly:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SeriesType.free:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
