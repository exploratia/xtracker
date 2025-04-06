import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../providers/series_current_value_provider.dart';
import '../../../../util/date_time_utils.dart';
import '../view/blood_pressure/table/blood_pressure_value_renderer.dart';

class SeriesLatestValue extends StatelessWidget {
  const SeriesLatestValue({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        {
          var bloodPressureValue = context.read<SeriesCurrentValueProvider>().bloodPressureCurrentValue(seriesDef);
          if (bloodPressureValue != null) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateTimeUtils.formateDate(bloodPressureValue.dateTime)),
                  Text(DateTimeUtils.formateTime(bloodPressureValue.dateTime)),
                  BloodPressureValueRenderer(bloodPressureValue: bloodPressureValue, seriesDef: seriesDef),
                ],
              ),
            );
          }
          return const Text("no data");
        }
      case SeriesType.dailyCheck:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SeriesType.monthly:
        // TODO: Handle this case.
        throw UnimplementedError();
      case SeriesType.free:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
