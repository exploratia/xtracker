import 'package:flutter/material.dart';

import '../../../../model/series/data/series_data_filter.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_type.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../model/series/view_type.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/select/day_range_slider.dart';
import '../../../controls/select/day_range_slider_overlay.dart';
import 'series_data_view_overlays.dart';
import 'series_title.dart';

class SeriesDataView extends StatelessWidget {
  const SeriesDataView({
    super.key,
    required this.seriesViewMetaData,
    required this.seriesDataValues,
    required this.seriesDataViewContentBuilder,
    required this.filter,
    required this.updateFilter,
    required this.seriesDataViewOverlays,
    required this.updateOverlays,
  });

  final SeriesViewMetaData seriesViewMetaData;
  final List<SeriesDataValue> seriesDataValues;
  final Widget Function() seriesDataViewContentBuilder;
  final SeriesDataFilter filter;
  final VoidCallback updateFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;
  final void Function({double? topHeight, double? bottomHeight}) updateOverlays;

  final bool _showTitle = true;

  @override
  Widget build(BuildContext context) {
    var seriesDef = seriesViewMetaData.seriesDef;

    List<Widget> stackChildren = [];

    // content
    stackChildren.add(Positioned.fill(
      child: seriesDataViewContentBuilder(),
    ));

    // title
    if (_showTitle) {
      WidgetsBinding.instance.addPostFrameCallback((_) => updateOverlays(topHeight: SeriesTitle.seriesTitleHeight));
      stackChildren.add(Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: SeriesTitle.seriesTitleHeight,
        child: IgnorePointer(
          child: SeriesTitle(seriesViewMetaData: seriesViewMetaData),
        ),
      ));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => updateOverlays(topHeight: 0));
    }

    // filter view
    var seriesType = seriesDef.seriesType;
    if (seriesViewMetaData.showDateFilter && [SeriesType.bloodPressure, SeriesType.dailyCheck, SeriesType.dailyLife, SeriesType.habit].contains(seriesType)) {
      stackChildren.add(Positioned.fill(
        child: _SeriesDataFilterView(
          seriesViewMetaData: seriesViewMetaData,
          seriesDataValues: seriesDataValues,
          filter: filter,
          updateFilter: updateFilter,
          seriesDataViewOverlays: seriesDataViewOverlays,
          updateOverlays: updateOverlays,
        ),
      ));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => updateOverlays(bottomHeight: 0));
    }

    return Stack(
      children: stackChildren,
    );
  }
}

class _SeriesDataFilterView extends StatelessWidget {
  const _SeriesDataFilterView({
    required this.seriesViewMetaData,
    required this.seriesDataValues,
    required this.filter,
    required this.updateFilter,
    required this.seriesDataViewOverlays,
    required this.updateOverlays,
  });

  final SeriesViewMetaData seriesViewMetaData;
  final List<SeriesDataValue> seriesDataValues;
  final SeriesDataFilter filter;
  final VoidCallback updateFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;
  final void Function({double? topHeight, double? bottomHeight}) updateOverlays;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // range slider date filter
        if ([ViewType.dots, ViewType.pixels, ViewType.table, ViewType.lineChart, ViewType.barChart].contains(seriesViewMetaData.viewType)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            double addHeightForTextScale = DayRangeSlider.calcAdditionalHeightByTextScale();
            updateOverlays(bottomHeight: ThemeUtils.seriesDataBottomFilterViewHeight + addHeightForTextScale);
          });

          int maxSpan = 366 * 2;

          // for charts wider maxSpan
          if ([ViewType.lineChart, ViewType.barChart].contains(seriesViewMetaData.viewType)) {
            maxSpan = 365 * 5;
          }

          return _StackedRangeSliderView(
            seriesData: seriesDataValues,
            seriesViewMetaData: seriesViewMetaData,
            maxSpan: maxSpan,
            filter: filter,
            updateFilter: updateFilter,
          );
        }

        // fallback no filter
        return Container();
      },
    );
  }
}

class _StackedRangeSliderView extends StatefulWidget {
  const _StackedRangeSliderView(
      {required this.seriesData, required this.seriesViewMetaData, required this.maxSpan, required this.filter, required this.updateFilter});

  final SeriesViewMetaData seriesViewMetaData;
  final List<SeriesDataValue> seriesData;
  final int maxSpan;
  final SeriesDataFilter filter;
  final VoidCallback updateFilter;

  @override
  State<_StackedRangeSliderView> createState() => _StackedRangeSliderViewState();
}

class _StackedRangeSliderViewState extends State<_StackedRangeSliderView> {
  /// oldest (most past) date
  late DateTime _firstDate;
  late DateTime _lastDate;

  @override
  void initState() {
    _firstDate = DateTimeUtils.truncateToDay(widget.seriesData.first.dateTime);
    _lastDate = DateTimeUtils.truncateToDay(widget.seriesData.last.dateTime);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant _StackedRangeSliderView oldWidget) {
    var afterUpdateFirstDate = DateTimeUtils.truncateToDay(widget.seriesData.first.dateTime);
    var afterUpdateLastDate = DateTimeUtils.truncateToDay(widget.seriesData.last.dateTime);
    if (_firstDate != afterUpdateFirstDate || _lastDate != afterUpdateLastDate) {
      setState(() {
        _firstDate = afterUpdateFirstDate;
        _lastDate = afterUpdateLastDate;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  void _setFilter(DayRange daysRange) {
    setState(() {
      var filterStartDate = daysRange.from;
      var filterEndDate = daysRange.till;
      // print("set dayRange: $daysRange -> $filterStartDate $filterEndDate");

      // set filter values null, if extreme values
      widget.filter.setDate(
        startDate: filterStartDate, //   (!filterStartDate.isAfter(_firstDate) ? null : filterStartDate),
        endDate: (!filterEndDate.isBefore(_lastDate) ? null : filterEndDate),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.updateFilter());
    });
  }

  @override
  Widget build(BuildContext context) {
    return DayRangeSliderOverlay(
      maxSpan: widget.maxSpan,
      dateRangeFrom: widget.seriesData.first.dateTime,
      dateRangeTill: widget.seriesData.last.dateTime,
      selectedDateRangeFrom: widget.filter.start,
      selectedDateRangeTill: widget.filter.end,
      setFilter: _setFilter,
    );
  }
}
