import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../model/series/data/custom/custom_value.dart';
import '../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../model/series/data/habit/habit_value.dart';
import '../../../../model/series/data/series_data.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../providers/series_current_value_provider.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/animation/animated_highlight_container.dart';
import 'series_value_renderer.dart';

class SeriesLatestValueRenderer extends StatelessWidget {
  const SeriesLatestValueRenderer({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    context.watch<SeriesCurrentValueProvider>();
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        {
          return AnimatedHighlightContainer<BloodPressureValue?>(
            highlightColor: seriesDef.color,
            valueSelector: (context) => context.read<SeriesCurrentValueProvider>().bloodPressureCurrentValue(seriesDef),
            // highlight initial if recently updated current value is the same type.
            // necessary, because of the onscreen keyboard shown up in the input dialog the whole series view is rebuild
            // without highlight initial the animation could never be seen
            highlightInitial: context.read<SeriesCurrentValueProvider>().recentlyUpdated() == seriesDef.seriesType,
            builder: (context, currentValue) {
              if (currentValue != null) {
                return _CurrentValueEdit(
                  seriesDef: seriesDef,
                  seriesDataValue: currentValue,
                  child: SeriesValueRenderer(currentValue, seriesDef: seriesDef),
                );
              }
              return Center(child: Text(LocaleKeys.seriesDefRenderer_currentValue_label_noValue.tr()));
            },
          );
        }
      case SeriesType.dailyCheck:
        {
          return AnimatedHighlightContainer<DailyCheckValue?>(
            highlightColor: seriesDef.color,
            valueSelector: (context) => context.read<SeriesCurrentValueProvider>().dailyCheckCurrentValue(seriesDef),
            builder: (context, currentValue) {
              if (currentValue != null) {
                return _CurrentValueEdit(
                  seriesDef: seriesDef,
                  seriesDataValue: currentValue,
                  child: SeriesValueRenderer(currentValue, seriesDef: seriesDef),
                );
              }
              return Center(child: Text(LocaleKeys.seriesDefRenderer_currentValue_label_noValue.tr()));
            },
          );
        }
      case SeriesType.dailyLife:
        {
          return AnimatedHighlightContainer<DailyLifeValue?>(
            highlightColor: seriesDef.color,
            valueSelector: (context) => context.read<SeriesCurrentValueProvider>().dailyLifeCurrentValue(seriesDef),
            builder: (context, currentValue) {
              if (currentValue != null) {
                return _CurrentValueEdit(
                  seriesDef: seriesDef,
                  seriesDataValue: currentValue,
                  child: SeriesValueRenderer(currentValue, seriesDef: seriesDef),
                );
              }
              return Center(child: Text(LocaleKeys.seriesDefRenderer_currentValue_label_noValue.tr()));
            },
          );
        }
      case SeriesType.habit:
        {
          return AnimatedHighlightContainer<HabitValue?>(
            highlightColor: seriesDef.color,
            valueSelector: (context) => context.read<SeriesCurrentValueProvider>().habitCurrentValue(seriesDef),
            builder: (context, currentValue) {
              if (currentValue != null) {
                return _CurrentValueEdit(
                  seriesDef: seriesDef,
                  seriesDataValue: currentValue,
                  child: SeriesValueRenderer(currentValue, seriesDef: seriesDef),
                );
              }
              return Center(child: Text(LocaleKeys.seriesDefRenderer_currentValue_label_noValue.tr()));
            },
          );
        }
      case SeriesType.custom:
      case SeriesType.monthly:
        {
          return AnimatedHighlightContainer<CustomValue?>(
            highlightColor: seriesDef.color,
            valueSelector: (context) => context.read<SeriesCurrentValueProvider>().customCurrentValue(seriesDef),
            builder: (context, currentValue) {
              if (currentValue != null) {
                return _CurrentValueEdit(
                  seriesDef: seriesDef,
                  seriesDataValue: currentValue,
                  child: SeriesValueRenderer(currentValue, seriesDef: seriesDef),
                );
              }
              return Center(child: Text(LocaleKeys.seriesDefRenderer_currentValue_label_noValue.tr()));
            },
          );
        }
    }
  }
}

class _CurrentValueEdit extends StatelessWidget {
  const _CurrentValueEdit({
    required this.seriesDef,
    required this.seriesDataValue,
    required this.child,
  });

  final SeriesDef seriesDef;
  final SeriesValueRenderer child;
  final SeriesDataValue seriesDataValue;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: LocaleKeys.seriesDefRenderer_currentValue_tooltip.tr(),
        child: InkWell(
          borderRadius: ThemeUtils.borderRadiusCircularSmall,
          onTap: () => SeriesData.showSeriesDataInputDlg(context, seriesDef, value: seriesDataValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.defaultPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}
