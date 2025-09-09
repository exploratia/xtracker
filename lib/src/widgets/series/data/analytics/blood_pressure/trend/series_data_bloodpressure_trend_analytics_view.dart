import 'dart:isolate';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../../../generated/assets.gen.dart';
import '../../../../../../../generated/locale_keys.g.dart';
import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/chart/chart_utils.dart';
import '../../../../../../util/forecast/forecast.dart';
import '../../../../../../util/forecast/trend/result/fit_result.dart';
import '../../../../../../util/forecast/trend/trend_analytics.dart';
import '../../../../../../util/forecast/trend/trend_data_values_datetime.dart';
import '../../../../../../util/forecast/trend_values_builder.dart';
import '../../../../../../util/media_query_utils.dart';
import '../../../../../../util/pair.dart';
import '../../../../../../util/table_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/future/future_builder_with_progress_indicator.dart';
import '../../habit/trend/series_data_habit_trend_analytics_view.dart';

class SeriesDataBloodPressureTrendAnalyticsView extends StatefulWidget {
  /// pixel and short day in headline width
  static double get _bloodPressureRendererWidth {
    return 30 * MediaQueryUtils.textScaleFactor + 6;
  }

  static const double _tendencyArrowWidth = 12;
  static const List<int> _dataBasisDays = [7, 30, 90, 365];

  const SeriesDataBloodPressureTrendAnalyticsView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<BloodPressureValue> seriesDataValues;

  @override
  State<SeriesDataBloodPressureTrendAnalyticsView> createState() => _SeriesDataBloodPressureTrendAnalyticsViewState();

  static Future<List<Pair<_FitResultWrapper, _FitResultWrapper>>> _calcTrends(List<BloodPressureValue> seriesDataValues) async {
    Future<List<Pair<_FitResultWrapper, _FitResultWrapper>>> exec(List<BloodPressureValue> seriesDataValues) async {
      Pair<TrendDataValuesDateTime, TrendDataValuesDateTime> trendDataValues = TrendValuesBuilder.buildForBloodPressure(seriesDataValues);
      List<Pair<_FitResultWrapper, _FitResultWrapper>> result = [];
      for (var trendDataBasisInDays in _dataBasisDays) {
        // if (trendDataValues.length >= trendDataBasisInDays) {
        var filteredTrendDataValuesHigh = trendDataValues.k.filterLastXDays(trendDataBasisInDays);
        var fitResultHigh = await TrendAnalytics.linear(filteredTrendDataValuesHigh);
        var filteredTrendDataValuesLow = trendDataValues.v.filterLastXDays(trendDataBasisInDays);
        var fitResultLow = await TrendAnalytics.linear(filteredTrendDataValuesLow);
        result.add(Pair(_FitResultWrapper(trendDataBasisInDays, fitResultHigh), _FitResultWrapper(trendDataBasisInDays, fitResultLow)));
        // }
      }
      return result;
    }

    if (kIsWeb) return exec(seriesDataValues);
    return await Isolate.run(() => exec(seriesDataValues));
  }
}

class _SeriesDataBloodPressureTrendAnalyticsViewState extends State<SeriesDataBloodPressureTrendAnalyticsView> {
  late Future<List<Pair<_FitResultWrapper, _FitResultWrapper>>> _calcTrendsFuture;

  @override
  void initState() {
    // if build is called multiple times because of state changes call future only once and store it.
    _calcTrendsFuture = SeriesDataBloodPressureTrendAnalyticsView._calcTrends(widget.seriesDataValues);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TrendViewSettingsCard(
      trendInfoDialogContent: const _TrendInfoDialogContent(),
      children: [
        FutureBuilderWithProgressIndicator(
          future: _calcTrendsFuture,
          errorBuilder: (error) => LocaleKeys.seriesDataAnalytics_trend_label_failedToCalculateTrend.tr(),
          widgetBuilder: (fitResultWrappersPairs, BuildContext context) {
            var mediaQueryUtils = MediaQueryUtils.of(context);
            int forecastDays = mediaQueryUtils.isTablet || mediaQueryUtils.isLandscape ? 14 : 7;

            List<TableRow> rows = TrendTable.buildKeyValueTableRowsWithForecastHeader(
              forecastDays,
              SeriesDataBloodPressureTrendAnalyticsView._bloodPressureRendererWidth,
              context,
            );

            for (var fitResultWrapperPair in fitResultWrappersPairs) {
              var fitResultWrapperHigh = fitResultWrapperPair.k;
              var fitResultHigh = fitResultWrapperHigh.fitResult;
              var fitResultLow = fitResultWrapperPair.v.fitResult;

              var keyWidget = Text(
                LocaleKeys.seriesDataAnalytics_label_lastXDays.tr(args: [fitResultWrapperHigh.dataBasisInDays.toString()]),
                softWrap: false,
              );

              Widget valueWidget;
              if (fitResultHigh.solvable) {
                valueWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: ThemeUtils.horizontalSpacing,
                      children: [
                        // Tendency arrow
                        SizedBox(
                          width: SeriesDataBloodPressureTrendAnalyticsView._tendencyArrowWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Tooltip(
                                message: fitResultHigh.getTendency().tooltip,
                                child: Text(fitResultHigh.getTendency().arrow),
                              ),
                              Tooltip(
                                message: fitResultLow.getTendency().tooltip,
                                child: Text(fitResultLow.getTendency().arrow),
                              ),
                            ],
                          ),
                        ),
                        // Preview
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: ThemeUtils.verticalSpacingSmall),
                          child: _TrendBloodPressurePreview(
                            seriesViewMetaData: widget.seriesViewMetaData,
                            forecastDays: forecastDays,
                            fitResultHigh: fitResultHigh,
                            fitResultLow: fitResultLow,
                          ),
                        ),
                      ],
                    ),
                    // Text(fitResultHigh.formula()),
                    // Text(fitResultLow.formula()),
                  ],
                );
              } else {
                valueWidget = Padding(
                  padding: const EdgeInsets.symmetric(vertical: ThemeUtils.verticalSpacingSmall),
                  child: Text(LocaleKeys.seriesDataAnalytics_trend_label_trendCalculationNotPossible.tr()),
                );
              }

              rows.add(TableUtils.tableRow([
                keyWidget,
                valueWidget,
              ]));
            }

            return TrendTable(rows: rows);
          },
        ),
      ],
    );
  }
}

class _TrendInfoDialogContent extends StatelessWidget {
  const _TrendInfoDialogContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: ThemeUtils.verticalSpacingLarge,
      children: [
        Text(LocaleKeys.seriesDataAnalytics_bloodPressure_trend_label_trendInfo.tr()),
        Image(
          image: Assets.images.trend.bloodPressureTrendInfo.provider(),
          height: 130,
          width: 250,
        ),
      ],
    );
  }
}

class _FitResultWrapper {
  final FitResult fitResult;
  final int dataBasisInDays;

  _FitResultWrapper(this.dataBasisInDays, this.fitResult);
}

class _TrendBloodPressurePreview extends StatelessWidget {
  final SeriesViewMetaData seriesViewMetaData;
  final FitResult fitResultHigh;
  final FitResult fitResultLow;
  final int forecastDays;

  const _TrendBloodPressurePreview({
    required this.seriesViewMetaData,
    required this.fitResultHigh,
    required this.fitResultLow,
    required this.forecastDays,
  });

  @override
  Widget build(BuildContext context) {
    final forecastValuesHigh = Forecast.buildDailyForecastValues(fitResultHigh, days: forecastDays);
    final forecastValuesLow = Forecast.buildDailyForecastValues(fitResultLow, days: forecastDays);

    // combine high low
    List<Pair<int, int>> combinedForecastValues = [];

    for (var i = 0; i < forecastValuesHigh.length; ++i) {
      var high = forecastValuesHigh[i].value?.toInt() ?? 0;
      var low = forecastValuesLow[i].value?.toInt() ?? 0;
      combinedForecastValues.add(Pair(high, low));
    }

    return Row(
      spacing: ThemeUtils.horizontalSpacingSmall,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...combinedForecastValues.map((fv) => _BloodPressureRenderer(fv.k, fv.v)),
      ],
    );
  }
}

class _BloodPressureRenderer extends StatelessWidget {
  const _BloodPressureRenderer(this.high, this.low);

  final int high;
  final int low;

  @override
  Widget build(BuildContext context) {
    Widget result = _Value(high, low);

    result = Container(
      width: SeriesDataBloodPressureTrendAnalyticsView._bloodPressureRendererWidth,
      decoration: BoxDecoration(
        borderRadius: ThemeUtils.borderRadiusCircularSmall,
        gradient: ChartUtils.createTopToBottomGradient(
          [
            BloodPressureValue.colorHigh(high),
            BloodPressureValue.colorLow(low),
          ],
        ),
      ),
      child: result,
    );

    return result;
  }
}

class _Value extends StatelessWidget {
  const _Value(this.high, this.low);

  final int high;
  final int low;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$high', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
          const Divider(thickness: 1, color: Colors.white),
          Text('$low', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
