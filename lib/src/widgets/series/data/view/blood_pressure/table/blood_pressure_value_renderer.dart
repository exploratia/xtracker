import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_def.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../../util/tooltip_utils.dart';

class BloodPressureValueRenderer extends StatelessWidget {
  static int height = 30;

  /// [showBorder] show a border around the value - fix true if [editMode] is set
  const BloodPressureValueRenderer({
    super.key,
    required this.bloodPressureValue,
    required this.seriesDef,
    this.editMode = false,
    this.showBorder = false,
    this.wrapWithDateTimeTooltip = false,
  });

  final BloodPressureValue bloodPressureValue;
  final bool editMode;
  final bool showBorder;
  final SeriesDef seriesDef;
  final bool wrapWithDateTimeTooltip;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    Widget result = _Value(bloodPressureValue: bloodPressureValue);

    if (editMode) {
      result = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: ThemeUtils.borderRadiusCircularSmall,
          onTap: () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: bloodPressureValue),
          child: result,
        ),
      );
    }

    result = Container(
      margin: const EdgeInsets.all(ThemeUtils.paddingSmall / 2),
      decoration: BoxDecoration(
        border: (showBorder || editMode) ? Border.all(width: 1, color: editMode ? themeData.colorScheme.secondary : themeData.cardColor) : null,
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
        gradient: LinearGradient(
          colors: [
            BloodPressureValue.colorHighOf(bloodPressureValue),
            BloodPressureValue.colorLowOf(bloodPressureValue),
          ],
        ),
      ),
      child: result,
    );

    if (wrapWithDateTimeTooltip) {
      result = Tooltip(
        message: '${DateTimeUtils.formateDate(bloodPressureValue.dateTime)}   ${DateTimeUtils.formateTime(bloodPressureValue.dateTime)}',
        textStyle: TooltipUtils.tooltipMonospaceStyle,
        child: result,
      );
    }

    return result;
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.bloodPressureValue,
  });

  final BloodPressureValue bloodPressureValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(width: 30, child: Text('${bloodPressureValue.high}', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)),
          bloodPressureValue.medication
              ? const Icon(
                  Icons.medication_outlined,
                  size: 16,
                  color: Colors.white,
                )
              : const SizedBox(height: 16, child: VerticalDivider(thickness: 1, width: 8, color: Colors.white)),
          SizedBox(width: 30, child: Text('${bloodPressureValue.low}', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
