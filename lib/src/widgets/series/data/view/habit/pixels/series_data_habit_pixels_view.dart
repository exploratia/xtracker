import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profiles.dart';
import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/grid/daily/day/habit_day_item.dart';
import '../../../../../controls/grid/daily/day_range_slider.dart';
import '../../../../../controls/grid/daily/pixel.dart';
import '../../../../../controls/grid/daily/row/row_item.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';

class SeriesDataHabitPixelsView extends StatefulWidget {
  final SeriesData<HabitValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;

  const SeriesDataHabitPixelsView({super.key, required this.seriesViewMetaData, required this.seriesData});

  @override
  State<SeriesDataHabitPixelsView> createState() => _SeriesDataHabitPixelsViewState();
}

class _SeriesDataHabitPixelsViewState extends State<SeriesDataHabitPixelsView> {
  /// from new to old (latest date is the first item)
  late List<HabitDayItem> _allDayItems;

  /// oldest date
  late DateTime _firstDate;
  late DateTime _filterStartDate = DateTimeUtils.truncateToDay(DateTime.now());
  late DateTime _filterEndDate = _filterStartDate.add(const Duration(days: 1));

  @override
  void initState() {
    _allDayItems = HabitDayItem.buildDayItems(widget.seriesData, widget.seriesViewMetaData.seriesDef);
    _firstDate = _allDayItems.last.dateTimeDayStart;

    _filterEndDate = DateTimeUtils.truncateToDay(DateTimeUtils.truncateToDay(_allDayItems.last.dateTimeDayStart).add(const Duration(hours: 36)));
    _filterStartDate = _filterEndDate.subtract(const Duration(hours: 12));

    super.initState();
  }

  void _setFilter(RangeValues daysRange) {
    setState(() {
      _filterStartDate = DateTimeUtils.truncateToDay(_firstDate.add(Duration(days: daysRange.start.toInt(), hours: 12)));
      _filterEndDate = DateTimeUtils.truncateToDay(_firstDate.add(Duration(days: daysRange.end.toInt() + 1, hours: 12)));
      // print("set dayRange: $daysRange -> $_filterStartDate $_filterEndDate');
    });
  }

  @override
  Widget build(BuildContext context) {
    Pixel.updatePixelStyles(context);
    var dayItems =
        _allDayItems.where((dayItem) => !dayItem.dateTimeDayStart.isBefore(_filterStartDate) && dayItem.dateTimeDayStart.isBefore(_filterEndDate)).toList();

    // determine max (min always 1)
    const minVal = 1;
    int maxVal = _allDayItems.map((e) => e.count).reduce((soFarMax, count) => max(soFarMax, count));
    Color baseColor = widget.seriesViewMetaData.seriesDef.color;
    var displaySettings = widget.seriesViewMetaData.seriesDef.displaySettingsReadonly();
    bool pixelsViewInvertHueDirection = displaySettings.pixelsViewInvertHueDirection;
    double pixelsViewHueFactor = displaySettings.pixelsViewHueFactor;

    // padding because of headline in stack
    return Padding(
      padding: const EdgeInsets.only(top: ThemeUtils.seriesDataViewTopPadding),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          bool monthly = constraints.maxWidth > FixColumnProfiles.columnProfileDateMonthDays.minWidth();

          List<RowItem<HabitDayItem>> data = monthly ? RowItem.buildMonthRowItems(dayItems) : RowItem.buildWeekRowItems(dayItems);

          gridCellBuilder(BuildContext context, int yIndex, int xIndex) {
            var rowItem = data[yIndex];

            if (xIndex == 0) {
              if (rowItem.displayDate != null) {
                return GridCell(child: Center(child: Text(rowItem.displayDate!)));
              }
              return GridCell(child: Container());
            }

            var dayItem = rowItem.getDayItem(xIndex - 1);
            if (dayItem == null) {
              return GridCell(child: Container());
            }

            return GridCell(
              child: dayItem.toPixel(
                monthly,
                [
                  if (dayItem.count > 0)
                    Pixel.pixelColor(baseColor, dayItem.count, minVal, maxVal,
                        invertHueDirection: pixelsViewInvertHueDirection, hueFactor: pixelsViewHueFactor),
                ],
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: constraints.maxHeight - 56,
                width: constraints.maxWidth,
                child: TwoDimensionalScrollableTable(
                  tableColumnProfile: monthly ? FixColumnProfiles.columnProfileDateMonthDays : FixColumnProfiles.columnProfileDateWeekdays,
                  lineCount: data.length,
                  gridCellBuilder: gridCellBuilder,
                  lineHeight: Pixel.pixelHeight,
                  useFixedFirstColumn: true,
                ),
              ),
              DayRangeSlider(
                date1: _allDayItems.first.dateTimeDayStart,
                date2: _allDayItems.last.dateTimeDayStart,
                maxSpan: 366 * 2,
                pageCallback: (daysRange) {
                  _setFilter(daysRange);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
