import 'dart:isolate';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../../../generated/assets.gen.dart';
import '../../../../../../../generated/locale_keys.g.dart';
import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/series_def.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/day_item/day_item.dart';
import '../../../../../../util/dialogs.dart';
import '../../../../../../util/forecast/forecast.dart';
import '../../../../../../util/forecast/trend/result/fit_result.dart';
import '../../../../../../util/forecast/trend/trend_analytics.dart';
import '../../../../../../util/forecast/trend/trend_data_values_datetime.dart';
import '../../../../../../util/forecast/trend_values_builder.dart';
import '../../../../../../util/forecast/weekday_probability_forecaster.dart';
import '../../../../../../util/media_query_utils.dart';
import '../../../../../../util/table_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/card/settings_card.dart';
import '../../../../../controls/future/future_builder_with_progress_indicator.dart';
import '../../../../../controls/grid/daily/pixel.dart';
import '../../../../../controls/layout/h_centered_scroll_view.dart';
import '../../../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../../../controls/text/overflow_text.dart';

class SeriesDataAnalyticsHabitTrendView extends StatefulWidget {
  /// pixel and short day in headline width
  static const double _pixelWidth = 32;
  static const double _tendencyArrowWidth = 20;

  static const List<int> _dataBasisDays = [7, 30, 90, 365];

  const SeriesDataAnalyticsHabitTrendView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<HabitValue> seriesDataValues;

  @override
  State<SeriesDataAnalyticsHabitTrendView> createState() => _SeriesDataAnalyticsHabitTrendViewState();

  static Future<List<_FitResultWrapper>> _calcTrends(List<HabitValue> seriesDataValues) async {
    Future<List<_FitResultWrapper>> exec(List<HabitValue> seriesDataValues) async {
      TrendDataValuesDateTime trendDataValues = TrendValuesBuilder.buildForHabit(seriesDataValues);
      List<_FitResultWrapper> result = [];
      for (var trendDataBasisInDays in _dataBasisDays) {
        // if (trendDataValues.length >= trendDataBasisInDays) {
        var filteredTrendDataValues = trendDataValues.filterLastXDays(trendDataBasisInDays);
        var weekDayProbabilities = WeekdayProbabilityForecaster.calcWeekDayProbability(filteredTrendDataValues, ignoreZeroValues: true);
        var fitResult = await TrendAnalytics.linear(filteredTrendDataValues);
        result.add(_FitResultWrapper(trendDataBasisInDays, fitResult, weekDayProbabilities));
        // }
      }
      return result;
    }

    if (kIsWeb) return exec(seriesDataValues);
    return await Isolate.run(() => exec(seriesDataValues));
  }
}

class _SeriesDataAnalyticsHabitTrendViewState extends State<SeriesDataAnalyticsHabitTrendView> {
  late Future<List<_FitResultWrapper>> _calcTrendsFuture;

  @override
  void initState() {
    // if build is called multiple times because of state changes call future only once and store it.
    _calcTrendsFuture = SeriesDataAnalyticsHabitTrendView._calcTrends(widget.seriesDataValues);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TrendViewSettingsCard(trendInfoDialogContent: const _TrendInfoDialogContent(), children: [
      FutureBuilderWithProgressIndicator(
        future: _calcTrendsFuture,
        errorBuilder: (error) => LocaleKeys.seriesDataAnalytics_trend_label_failedToCalculateTrend.tr(),
        widgetBuilder: (fitResultWrappers, BuildContext context) {
          // determine all time max value (for correct max pixel color)
          var dayItems = DayItem.buildDayItems(widget.seriesDataValues, (day) => DayItem(day));
          int maxItemsOnSingleDay = dayItems.fold(0, (previousValue, element) => math.max(previousValue, element.dateTimeItems.length));

          var mediaQueryUtils = MediaQueryUtils.of(context);
          int forecastDays = mediaQueryUtils.isTablet || mediaQueryUtils.isLandscape ? 14 : 7;

          List<TableRow> rows = TrendTable.buildKeyValueTableRowsWithForecastHeader(
            forecastDays,
            SeriesDataAnalyticsHabitTrendView._pixelWidth /* same as in trend_pixel_preview */,
            context,
          );

          for (var fitResultWrapper in fitResultWrappers) {
            var fitResult = fitResultWrapper.fitResult;

            var keyWidget = Text(
              LocaleKeys.seriesDataAnalytics_label_lastVarDays.tr(args: [fitResultWrapper.dataBasisInDays.toString()]),
              softWrap: false,
            );

            Widget valueWidget;
            if (fitResult.solvable) {
              valueWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    spacing: ThemeUtils.horizontalSpacing,
                    children: [
                      // Tendency arrow
                      SizedBox(
                        width: SeriesDataAnalyticsHabitTrendView._tendencyArrowWidth,
                        child: Tooltip(
                          message: fitResult.getTendency().tooltip,
                          child: Icon(
                            fitResult.getTendency().arrow,
                            size: SeriesDataAnalyticsHabitTrendView._tendencyArrowWidth,
                          ),
                        ),
                      ),
                      // PixelPreview
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: ThemeUtils.verticalSpacingSmall),
                        child: _TrendPixelPreview(
                          seriesViewMetaData: widget.seriesViewMetaData,
                          weekdayPosteriors: fitResultWrapper.weekdayPosteriors,
                          allTimeMaxValue: maxItemsOnSingleDay,
                          forecastDays: forecastDays,
                          fitResultWrapper: fitResultWrapper,
                        ),
                      ),
                    ],
                  ),
                  // Text(fitResult.formula()),
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
    ]);
  }
}

class TrendViewSettingsCard extends StatelessWidget {
  const TrendViewSettingsCard({
    super.key,
    required this.trendInfoDialogContent,
    required this.children,
  });

  final Widget trendInfoDialogContent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: Row(
        spacing: ThemeUtils.horizontalSpacing,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OverflowText(
            LocaleKeys.seriesDataAnalytics_trend_title.tr(),
            style: Theme.of(context).textTheme.titleLarge,
            expanded: false,
            flexible: true,
          ),
          IconButton(
            tooltip: LocaleKeys.commons_btn_info_tooltip.tr(),
            onPressed: () => Dialogs.simpleOkDialog(
              SingleChildScrollViewWithScrollbar(
                useHorizontalScreenPaddingForScrollbar: true,
                child: trendInfoDialogContent,
              ),
              context,
              title: LocaleKeys.seriesDataAnalytics_trend_title.tr(),
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      children: children,
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
        Text(LocaleKeys.seriesDataAnalytics_habit_trend_label_trendInfo.tr()),
        Image(
          image: Assets.images.trend.habitTrendInfo.provider(),
          height: 130,
          width: 250,
        ),
      ],
    );
  }
}

class TrendTable extends StatelessWidget {
  const TrendTable({
    super.key,
    required this.rows,
  });

  final List<TableRow> rows;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return HCenteredScrollView(
      children: [
        Table(
          columnWidths: <int, TableColumnWidth>{
            0: const FixedColumnWidth(120),
            1: const IntrinsicColumnWidth(),
          },
          border: TableBorder.symmetric(
            inside: BorderSide(width: 1, color: themeData.canvasColor),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: rows,
        ),
      ],
    );
  }

  static List<TableRow> buildKeyValueTableRowsWithForecastHeader(int forecastDays, double dayColumnWidth, BuildContext context) {
    // build next forecast days shortDay names list
    final today = DateTimeUtils.truncateToMidDay(DateTime.now());
    var dayNames = List<String>.generate(forecastDays, (i) {
      final day = today.add(Duration(days: i + 1));
      return DateTimeUtils.formateShortDay(day);
    });

    List<TableRow> rows = TableUtils.buildKeyValueTableRows(
      context,
      keyColumnTitle: LocaleKeys.seriesDataAnalytics_label_dataset.tr(),
      valueColumnTitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: ThemeUtils.verticalSpacingSmall,
        children: [
          Text(LocaleKeys.seriesDataAnalytics_trend_label_forecast.tr()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: ThemeUtils.horizontalSpacing,
            children: [
              const SizedBox(width: SeriesDataAnalyticsHabitTrendView._tendencyArrowWidth),
              Row(
                spacing: ThemeUtils.horizontalSpacingSmall,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...dayNames.map(
                    (e) => SizedBox(
                      width: dayColumnWidth,
                      child: Center(child: Text(e)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    return rows;
  }
}

class _FitResultWrapper {
  final FitResult fitResult;
  final int dataBasisInDays;
  final WeekdayPosteriors weekdayPosteriors;

  _FitResultWrapper(this.dataBasisInDays, this.fitResult, this.weekdayPosteriors);
}

class _TrendPixelPreview extends StatelessWidget {
  final SeriesViewMetaData seriesViewMetaData;
  final _FitResultWrapper fitResultWrapper;
  final WeekdayPosteriors weekdayPosteriors;

  /// max "value" of all series data to be able to show the correct pixel color
  final int allTimeMaxValue;
  final int forecastDays;

  const _TrendPixelPreview({
    required this.seriesViewMetaData,
    required this.fitResultWrapper,
    required this.weekdayPosteriors,
    required this.allTimeMaxValue,
    required this.forecastDays,
  });

  @override
  Widget build(BuildContext context) {
    final SeriesDef seriesDef = seriesViewMetaData.seriesDef;
    final settings = seriesViewMetaData.seriesDef.displaySettingsReadonly();
    final color = seriesDef.color;
    final invertHueDirection = settings.pixelsViewInvertHueDirection;
    final hueFactor = settings.pixelsViewHueFactor;
    final forecastValues = Forecast.buildDailyForecastValues(fitResultWrapper.fitResult, days: forecastDays);
    final themeData = Theme.of(context);
    var maxForecastValue = forecastValues.fold(0.0, (previousValue, fv) => fv.value == null ? previousValue : math.max(previousValue, fv.value!));
    var maxCombinedValue = math.max(maxForecastValue, allTimeMaxValue);
    return Row(
      spacing: ThemeUtils.horizontalSpacingSmall,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...forecastValues.map(
          (fv) {
            int? i = fv.value?.round();
            int weekday = fv.date.weekday;
            var opacity = weekdayPosteriors.weekdayPosterior(weekday);
            Widget pixel;
            if (opacity < 0.1 || i == null || i < 1) {
              pixel = Opacity(opacity: 0.3, child: Pixel(colors: [themeData.scaffoldBackgroundColor]));
            } else {
              pixel = Opacity(
                opacity: opacity,
                child: Pixel(
                  colors: [Pixel.pixelColor(color, i, 1, maxCombinedValue, hueFactor: hueFactor, invertHueDirection: invertHueDirection)],
                  pixelText: i.toString(),
                ),
              );
            }
            return SizedBox(
              width: SeriesDataAnalyticsHabitTrendView._pixelWidth,
              height: Pixel.pixelHeight.toDouble(),
              child: pixel,
            );
          },
        ),
      ],
    );
  }
}
