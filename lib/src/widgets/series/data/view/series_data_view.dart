import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/data/habit/habit_value.dart';
import '../../../../model/series/data/series_data.dart';
import '../../../../model/series/data/series_data_filter.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_type.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../model/series/view_type.dart';
import '../../../../providers/series_data_provider.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/tooltip_utils.dart';
import '../../../controls/animation/fade_in.dart';
import '../../../controls/layout/centered_message.dart';
import '../../../controls/navigation/hide_bottom_navigation_bar.dart';
import '../../../controls/provider/data_provider_loader.dart';
import '../../../controls/select/day_range_slider.dart';
import '../../../controls/text/overflow_text.dart';
import 'blood_pressure/series_data_blood_pressure_view.dart';
import 'daily_check/series_data_daily_check_view.dart';
import 'habit/series_data_habit_view.dart';

class SeriesDataView extends StatelessWidget {
  const SeriesDataView({super.key, required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    TooltipUtils.updateTooltipMonospaceStyle(context);

    return HideBottomNavigationBar(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        spacing: 0,
        children: [
          _Title(seriesViewMetaData: seriesViewMetaData),
          Expanded(
            child: DataProviderLoader(
              obtainDataProviderFuture: context.read<SeriesDataProvider>().fetchDataIfNotYetLoaded(seriesViewMetaData.seriesDef),
              progressIndicatorMarginTop: 24,
              child: _SeriesDataView(seriesViewMetaData: seriesViewMetaData),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesDataView extends StatelessWidget {
  const _SeriesDataView({required this.seriesViewMetaData});

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    var seriesDef = seriesViewMetaData.seriesDef;

    var seriesDataProvider = context.watch<SeriesDataProvider>();

    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        var seriesData = seriesDataProvider.bloodPressureData(seriesDef);
        if (_NoDataMsg.isNoData(seriesData)) return _NoDataMsg(seriesViewMetaData: seriesViewMetaData);
        return SeriesDataBloodPressureView(seriesViewMetaData: seriesViewMetaData);
      case SeriesType.dailyCheck:
        var seriesData = seriesDataProvider.dailyCheckData(seriesDef);
        if (_NoDataMsg.isNoData(seriesData)) return _NoDataMsg(seriesViewMetaData: seriesViewMetaData);
        return SeriesDataDailyCheckView(seriesViewMetaData: seriesViewMetaData);
      case SeriesType.habit:
        var seriesData = seriesDataProvider.habitData(seriesDef);
        if (_NoDataMsg.isNoData(seriesData)) return _NoDataMsg(seriesViewMetaData: seriesViewMetaData);
        return _SeriesDataFilterView<HabitValue>(
          seriesViewMetaData: seriesViewMetaData,
          seriesData: seriesData!.data,
          seriesDataViewBuilder: (SeriesDataFilter filter) => SeriesDataHabitView(
            seriesViewMetaData: seriesViewMetaData,
            seriesData: seriesData.data,
            seriesDataFilter: filter,
          ),
        );
    }
  }
}

class _SeriesDataFilterView<T extends SeriesDataValue> extends StatelessWidget {
  const _SeriesDataFilterView({super.key, required this.seriesData, required this.seriesViewMetaData, required this.seriesDataViewBuilder});

  final SeriesViewMetaData seriesViewMetaData;
  final List<T> seriesData;
  final Widget Function(SeriesDataFilter filter) seriesDataViewBuilder;

  @override
  Widget build(BuildContext context) {
    if (seriesViewMetaData.seriesDef.seriesType == SeriesType.habit && seriesViewMetaData.viewType == ViewType.pixels) {
      return _StackedRangeSliderView(
        seriesData: seriesData,
        seriesViewMetaData: seriesViewMetaData,
        seriesDataViewBuilder: seriesDataViewBuilder,
      );
    }

    // fallback no filter
    return seriesDataViewBuilder(SeriesDataFilter());
  }
}

class _StackedRangeSliderView<T extends SeriesDataValue> extends StatefulWidget {
  const _StackedRangeSliderView({super.key, required this.seriesData, required this.seriesViewMetaData, required this.seriesDataViewBuilder});

  final SeriesViewMetaData seriesViewMetaData;
  final List<T> seriesData;
  final Widget Function(SeriesDataFilter filter) seriesDataViewBuilder;

  @override
  State<_StackedRangeSliderView> createState() => _StackedRangeSliderViewState<T>();
}

class _StackedRangeSliderViewState<T extends SeriesDataValue> extends State<_StackedRangeSliderView<T>> {
  SeriesDataFilter filter = SeriesDataFilter();
  bool _sliderVisible = false;

  /// oldest (most past) date
  late DateTime _firstDate;
  late DateTime _filterStartDate;
  late DateTime _filterEndDate;

  @override
  void initState() {
    _firstDate = widget.seriesData.first.dateTime;

    _filterEndDate = DateTimeUtils.truncateToDay(DateTimeUtils.truncateToDay(widget.seriesData.last.dateTime).add(const Duration(hours: 36)));
    _filterStartDate = _filterEndDate.subtract(const Duration(hours: 12));

    filter.start = _filterStartDate;
    filter.end = _filterEndDate;

    super.initState();
  }

  void _setFilter(RangeValues daysRange) {
    setState(() {
      _filterStartDate = DateTimeUtils.truncateToDay(_firstDate.add(Duration(days: daysRange.start.toInt(), hours: 12)));
      _filterEndDate = DateTimeUtils.truncateToDay(_firstDate.add(Duration(days: daysRange.end.toInt() + 1, hours: 12)));
      // print("set dayRange: $daysRange -> $_filterStartDate $_filterEndDate');

      filter.start = _filterStartDate;
      filter.end = _filterEndDate;
    });
  }

  void _setSliderVisible(bool visible) {
    setState(() {
      _sliderVisible = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: widget.seriesDataViewBuilder(filter),
        ),
        AnimatedPositioned(
          height: _sliderVisible ? 78 : 48,
          left: 0,
          right: 0,
          bottom: 0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: themeData.scaffoldBackgroundColor.withAlpha(128),
            child: DayRangeSlider(
                pageCallback: _setFilter,
                maxSpan: 366 * 2,
                sliderInitialVisible: false,
                sliderVisibleCallback: _setSliderVisible,
                date1: widget.seriesData.first.dateTime,
                date2: widget.seriesData.last.dateTime),
          ),
        )
      ],
    );
  }
}

class _NoDataMsg extends StatelessWidget {
  const _NoDataMsg({
    required this.seriesViewMetaData,
  });

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    return CenteredMessage(
      message: IntrinsicHeight(
        child: FadeIn(
          child: Column(
            children: [
              Icon(seriesViewMetaData.seriesDef.iconData(), color: seriesViewMetaData.seriesDef.color, size: 40),
              Text(LocaleKeys.seriesData_label_noData.tr()),
            ],
          ),
        ),
      ),
    );
  }

  static bool isNoData(SeriesData<dynamic>? seriesData) {
    return (seriesData == null || seriesData.isEmpty());
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.seriesViewMetaData,
  });

  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const AlignmentDirectional(0, -1),
                end: const AlignmentDirectional(0, 1),
                colors: [
                  themeData.colorScheme.primary,
                  seriesViewMetaData.seriesDef.color,
                ],
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: seriesViewMetaData.seriesDef.color.withValues(alpha: 0.8), // Glow effect
                  blurRadius: 10,
                  spreadRadius: 1, // Intensity of the glow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1, top: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: themeData.scaffoldBackgroundColor, // Inner background color
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IntrinsicWidth(
                    child: Row(
                      spacing: 8,
                      children: [
                        Hero(tag: 'seriesDef_${seriesViewMetaData.seriesDef.uuid}', child: seriesViewMetaData.seriesDef.icon()),
                        OverflowText(
                          seriesViewMetaData.seriesDef.name,
                          expanded: true,
                          style: themeData.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
