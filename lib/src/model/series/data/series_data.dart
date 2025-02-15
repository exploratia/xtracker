import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../providers/series_data_provider.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../widgets/series/data/input/blood_pressure/blood_pressure_quick_input.dart';
import '../series_def.dart';
import '../series_type.dart';
import 'series_data_value.dart';

class SeriesData<T extends SeriesDataValue> {
  /// same as in SeriesDef
  final String uuid;

  final List<T> seriesItems;

  SeriesData(this.uuid, this.seriesItems);

  bool isEmpty() {
    return seriesItems.isEmpty;
  }

  void add(T value) {
    seriesItems.add(value);
  }

  static showSeriesDataInputDlg(BuildContext context, SeriesDef seriesDef) async {
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        var val = await BloodPressureQuickInput.showInputDlg(context, seriesDef);
        if (val == null) return;
        if (context.mounted) {
          var seriesDataProvider = context.read<SeriesDataProvider>();
          await seriesDataProvider.fetchDataIfNotYetLoaded(seriesDef);
          var bloodPressureSeriesData = seriesDataProvider.bloodPressureData(seriesDef);
          if (bloodPressureSeriesData == null) {
            if (context.mounted) {
              Dialogs.simpleErrOkDialog("Failed to store series value!", context);
            } else {
              SimpleLogging.w("Failed to store series value vor series '${seriesDef.uuid}'! SeriesData is null.");
            }
            return;
          }
          bloodPressureSeriesData.add(val);
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
