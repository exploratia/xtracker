import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../providers/series_data_provider.dart';
import '../../../util/dialogs.dart';
import '../../../widgets/series/data/input/blood_pressure/blood_pressure_quick_input.dart';
import '../series_def.dart';
import '../series_type.dart';
import 'blood_pressure/blood_pressure_value.dart';
import 'series_data_value.dart';

class SeriesData<T extends SeriesDataValue> {
  /// same as in SeriesDef
  final String uuid;

  final List<T> seriesItems;

  SeriesData(this.uuid, this.seriesItems);

  bool isEmpty() {
    return seriesItems.isEmpty;
  }

  void insert(T value) {
    seriesItems.add(value);
    // sort - probably not necessary but maybe date could also be set?
    seriesItems.sort((a, b) => a.dateTime.millisecondsSinceEpoch.compareTo(b.dateTime.millisecondsSinceEpoch));
  }

  void update(T value) {
    var idx = seriesItems.indexWhere((element) => element.uuid == value.uuid);
    if (idx < 0) return;
    seriesItems.removeAt(idx);
    seriesItems.insert(idx, value);
  }

  void delete(T value) {
    seriesItems.remove(value);
  }

  void deleteById(String uuid) {
    seriesItems.removeWhere((element) => element.uuid == uuid);
  }

  static showSeriesDataInputDlg(BuildContext context, SeriesDef seriesDef, {dynamic value}) async {
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        BloodPressureValue? bloodPressureValue;
        if (value is BloodPressureValue) bloodPressureValue = value;
        var val = await BloodPressureQuickInput.showInputDlg(context, seriesDef, bloodPressureValue: bloodPressureValue);
        if (val == null) return;
        if (context.mounted) {
          var seriesDataProvider = context.read<SeriesDataProvider>();

          try {
            if (bloodPressureValue == null) {
              await seriesDataProvider.addValue(seriesDef, val); // insert
            } else {
              await seriesDataProvider.updateValue(seriesDef, val); // update
            }
          } catch (ex) {
            if (context.mounted) {
              Dialogs.simpleErrOkDialog(ex.toString(), context);
            }
          }
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
