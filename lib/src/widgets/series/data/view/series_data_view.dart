import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../model/series/data/habit/habit_value.dart';
import '../../../../model/series/data/series_data_filter.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_type.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../model/series/view_type.dart';
import '../../../../providers/series_data_provider.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../../util/tooltip_utils.dart';
import '../../../controls/navigation/hide_bottom_navigation_bar.dart';
import '../../../controls/provider/data_provider_loader.dart';
import '../../../controls/select/day_range_slider.dart';
import 'blood_pressure/series_data_blood_pressure_view.dart';
import 'daily_check/series_data_daily_check_view.dart';
import 'habit/series_data_habit_view.dart';
import 'series_data_no_data.dart';
import 'series_title.dart';

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
          SeriesTitle(seriesViewMetaData: seriesViewMetaData),
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
        if (SeriesDataNoData.isNoData(seriesData)) return SeriesDataNoData(seriesViewMetaData: seriesViewMetaData);
        return _SeriesDataFilterView<BloodPressureValue>(
          seriesViewMetaData: seriesViewMetaData,
          seriesData: seriesData!.data,
          seriesDataViewBuilder: (SeriesDataFilter filter) => SeriesDataBloodPressureView(
            seriesViewMetaData: seriesViewMetaData,
            seriesData: seriesData.data,
            seriesDataFilter: filter,
          ),
        );
      case SeriesType.dailyCheck:
        var seriesData = seriesDataProvider.dailyCheckData(seriesDef);
        if (SeriesDataNoData.isNoData(seriesData)) return SeriesDataNoData(seriesViewMetaData: seriesViewMetaData);
        return _SeriesDataFilterView<DailyCheckValue>(
          seriesViewMetaData: seriesViewMetaData,
          seriesData: seriesData!.data,
          seriesDataViewBuilder: (SeriesDataFilter filter) => SeriesDataDailyCheckView(
            seriesViewMetaData: seriesViewMetaData,
            seriesData: seriesData.data,
            seriesDataFilter: filter,
          ),
        );
      case SeriesType.habit:
        var seriesData = seriesDataProvider.habitData(seriesDef);
        if (SeriesDataNoData.isNoData(seriesData)) return SeriesDataNoData(seriesViewMetaData: seriesViewMetaData);
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
    if (seriesViewMetaData.viewType == ViewType.dots || seriesViewMetaData.viewType == ViewType.pixels || seriesViewMetaData.viewType == ViewType.table) {
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
    _filterStartDate = _filterEndDate;

    filter.start = _filterStartDate;
    filter.end = _filterEndDate;

    super.initState();
  }

  @override
  void didUpdateWidget(covariant _StackedRangeSliderView<T> oldWidget) {
    if (_firstDate != widget.seriesData.first.dateTime) {
      setState(() {
        _firstDate = widget.seriesData.first.dateTime;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void _setFilter(RangeValues daysRange) {
    setState(() {
      var firstDateDayStart = DateTimeUtils.truncateToDay(_firstDate);
      _filterStartDate = DateTimeUtils.truncateToDay(firstDateDayStart.add(Duration(days: daysRange.start.toInt(), hours: 12)));
      _filterEndDate = DateTimeUtils.truncateToDay(firstDateDayStart.add(Duration(days: daysRange.end.toInt() + 1, hours: 12))); // next day start
      // print("set dayRange: $daysRange -> $_filterStartDate $_filterEndDate");

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
          height: ThemeUtils.seriesDataBottomFilterViewHeight * (_sliderVisible ? 2 : 1),
          left: 0,
          right: 0,
          bottom: 0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            child: Container(
              color: themeData.scaffoldBackgroundColor.withAlpha(128),
            ),
          ),
        ),
        AnimatedPositioned(
          height: ThemeUtils.seriesDataBottomFilterViewHeight * (_sliderVisible ? 2 : 1),
          left: 0,
          right: 0,
          bottom: 0,
          duration: const Duration(milliseconds: 300),
          child: DayRangeSlider(
              pageCallback: _setFilter,
              maxSpan: 366 * 2,
              sliderInitialVisible: false,
              sliderVisibleCallback: _setSliderVisible,
              date1: widget.seriesData.first.dateTime,
              date2: widget.seriesData.last.dateTime),
        ),
      ],
    );
  }
}
