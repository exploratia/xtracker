import 'package:flutter/material.dart';

import '../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../model/series/data/free/multi_value.dart';
import '../../../../model/series/data/habit/habit_value.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_def.dart';
import '../../../../model/series/series_type.dart';
import '../../../../model/series/settings/daily_life/daily_life_attribute_resolver.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/logging/flutter_simple_logging.dart';
import '../../../../util/theme_utils.dart';
import 'blood_pressure/table/blood_pressure_value_renderer.dart';
import 'daily_check/table/daily_check_value_renderer.dart';
import 'daily_life/daily_life_attribute_renderer.dart';
import 'free/table/multi_value_renderer.dart';
import 'habit/table/habit_value_renderer.dart';

class SeriesValueRenderer<T extends SeriesDataValue> extends StatelessWidget {
  const SeriesValueRenderer(
    this._seriesDataValue, {
    super.key,
    required this.seriesDef,
  });

  final T _seriesDataValue;
  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    Widget? valueRenderer;

    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        if (_seriesDataValue is BloodPressureValue) {
          valueRenderer = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BloodPressureValueRenderer(bloodPressureValue: _seriesDataValue, seriesDef: seriesDef),
            ],
          );
        }
      case SeriesType.dailyCheck:
        if (_seriesDataValue is DailyCheckValue) {
          valueRenderer = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DailyCheckValueRenderer(dailyCheckValue: _seriesDataValue, seriesDef: seriesDef),
            ],
          );
        }
      case SeriesType.habit:
        if (_seriesDataValue is HabitValue) {
          valueRenderer = HabitValueRenderer(habitValue: _seriesDataValue, seriesDef: seriesDef);
        }
      case SeriesType.dailyLife:
        if (_seriesDataValue is DailyLifeValue) {
          valueRenderer = Builder(
            builder: (context) {
              var resolver = DailyLifeAttributeResolver(seriesDef);
              return DailyLifeAttributeRenderer(dailyLifeAttribute: resolver.resolve(_seriesDataValue.aid));
            },
          );
        }
      case SeriesType.free:
      case SeriesType.monthly:
        if (_seriesDataValue is MultiValue) {
          valueRenderer = MultiValueRenderer(multiValue: _seriesDataValue, seriesDef: seriesDef);
        }
    }

    if (valueRenderer != null) {
      return ValueWrap(
        children: [
          Text(DateTimeUtils.formatDate(_seriesDataValue.dateTime)),
          Text(DateTimeUtils.formatTime(_seriesDataValue.dateTime)),
          valueRenderer,
        ],
      );
    }

    SimpleLogging.w(
        "Invalid combination of seriesDef ''${seriesDef.seriesType} and seriesDataValue '${_seriesDataValue.runtimeType}' in series value renderer!");
    return const Icon(Icons.question_mark_outlined);
  }
}

class ValueWrap extends StatelessWidget {
  const ValueWrap({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: ThemeUtils.horizontalSpacing,
      runSpacing: ThemeUtils.verticalSpacingSmall,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
