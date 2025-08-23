import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../model/series/data/habit/habit_value.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../providers/series_current_value_provider.dart';
import '../../../../util/date_time_utils.dart';
import '../../../controls/animation/animated_highlight_container.dart';
import 'blood_pressure/table/blood_pressure_value_renderer.dart';
import 'daily_check/table/daily_check_value_renderer.dart';
import 'habit/table/habit_value_renderer.dart';

class SeriesLatestValueRenderer extends StatelessWidget {
  const SeriesLatestValueRenderer({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        {
          return AnimatedHighlightContainer<BloodPressureValue?>(
              highlightColor: seriesDef.color,
              valueSelector: (context) => context.read<SeriesCurrentValueProvider>().bloodPressureCurrentValue(seriesDef),
              builder: (context, currentValue) {
                if (currentValue != null) {
                  return _LatestValueWrap(
                    children: [
                      Text(DateTimeUtils.formateDate(currentValue.dateTime)),
                      Text(DateTimeUtils.formateTime(currentValue.dateTime)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BloodPressureValueRenderer(bloodPressureValue: currentValue, seriesDef: seriesDef),
                        ],
                      ),
                    ],
                  );
                }
                return Center(child: Text(LocaleKeys.seriesDefRenderer_label_noValue.tr()));
              });
        }
      case SeriesType.dailyCheck:
        {
          return AnimatedHighlightContainer<DailyCheckValue?>(
              highlightColor: seriesDef.color,
              valueSelector: (context) => context.read<SeriesCurrentValueProvider>().dailyCheckCurrentValue(seriesDef),
              builder: (context, currentValue) {
                if (currentValue != null) {
                  return _LatestValueWrap(children: [
                    Text(DateTimeUtils.formateDate(currentValue.dateTime)),
                    Text(DateTimeUtils.formateTime(currentValue.dateTime)),
                    DailyCheckValueRenderer(dailyCheckValue: currentValue, seriesDef: seriesDef),
                  ]);
                }
                return Center(child: Text(LocaleKeys.seriesDefRenderer_label_noValue.tr()));
              });
        }
      case SeriesType.habit:
        {
          return AnimatedHighlightContainer<HabitValue?>(
              highlightColor: seriesDef.color,
              valueSelector: (context) => context.read<SeriesCurrentValueProvider>().habitCurrentValue(seriesDef),
              builder: (context, currentValue) {
                if (currentValue != null) {
                  return _LatestValueWrap(children: [
                    Text(DateTimeUtils.formateDate(currentValue.dateTime)),
                    Text(DateTimeUtils.formateTime(currentValue.dateTime)),
                    HabitValueRenderer(habitValue: currentValue, seriesDef: seriesDef),
                  ]);
                }
                return Center(child: Text(LocaleKeys.seriesDefRenderer_label_noValue.tr()));
              });
        }
    }
  }
}

class _LatestValueWrap extends StatelessWidget {
  const _LatestValueWrap({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
