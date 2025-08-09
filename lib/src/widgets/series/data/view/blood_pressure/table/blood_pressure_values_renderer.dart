import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/tooltip_utils.dart';
import 'blood_pressure_value_renderer.dart';

class BloodPressureValuesRenderer extends StatelessWidget {
  const BloodPressureValuesRenderer({super.key, required this.bloodPressureValues, required this.seriesViewMetaData, this.showBorder = false});

  final List<BloodPressureValue> bloodPressureValues;
  final SeriesViewMetaData seriesViewMetaData;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    if (bloodPressureValues.isEmpty) return Container();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...bloodPressureValues.map(
          (bpv) => Tooltip(
            message: '${DateTimeUtils.formateDate(bpv.dateTime)}   ${DateTimeUtils.formateTime(bpv.dateTime)}',
            textStyle: TooltipUtils.tooltipMonospaceStyle,
            child: BloodPressureValueRenderer(
              key: Key('bloodPressureValue_${bpv.uuid}'),
              bloodPressureValue: bpv,
              seriesDef: seriesViewMetaData.seriesDef,
              editMode: seriesViewMetaData.editMode,
              showBorder: showBorder,
            ),
          ),
        ),
      ],
    );
  }
}
