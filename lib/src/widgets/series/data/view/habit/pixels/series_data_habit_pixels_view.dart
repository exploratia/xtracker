import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profile.dart';
import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../controls/grid/daily/day/habit_day_item.dart';
import '../../../../../controls/grid/daily/pixel.dart';
import '../../../../../controls/grid/daily/pixel_cell_builder.dart';
import '../../../../../controls/grid/daily/row/row_item.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';

class SeriesDataHabitPixelsView extends StatelessWidget {
  final List<HabitValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  const SeriesDataHabitPixelsView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

  @override
  Widget build(BuildContext context) {
    Pixel.updatePixelStyles(context);

    /// from new to old (latest date is the first item)
    List<HabitDayItem> allDayItems = HabitDayItem.buildDayItems(seriesData, seriesViewMetaData.seriesDef);
    var dayItems = allDayItems.where((dayItem) => seriesDataFilter.filterDate(dayItem.dayDate)).toList();

    if (dayItems.isEmpty || dayItems.where((i) => i.count > 0).isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    // determine max (min always 1)
    const minVal = 1;
    int maxVal = allDayItems.map((e) => e.count).reduce((soFarMax, count) => max(soFarMax, count));

    Color baseColor = seriesViewMetaData.seriesDef.color;
    var displaySettings = seriesViewMetaData.seriesDef.displaySettingsReadonly();
    bool pixelsViewInvertHueDirection = displaySettings.pixelsViewInvertHueDirection;
    double pixelsViewHueFactor = displaySettings.pixelsViewHueFactor;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool monthly = constraints.maxWidth > FixColumnProfile.columnProfileDateMonthDays.minWidthScaled();

        List<RowItem<HabitDayItem>> data = monthly ? RowItem.buildMonthRowItems(dayItems) : RowItem.buildWeekRowItems(dayItems);

        var pixelCellBuilder = PixelCellBuilder(
          data: data,
          monthly: monthly,
          gridCellChildBuilder: (HabitDayItem dayItem) {
            return dayItem.toPixel(
              monthly,
              [Pixel.pixelColor(baseColor, dayItem.count, minVal, maxVal, invertHueDirection: pixelsViewInvertHueDirection, hueFactor: pixelsViewHueFactor)],
            );
          },
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 0,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            seriesDataViewOverlays.buildTopSpacer(),
            Expanded(
              child: TwoDimensionalScrollableTable(
                tableColumnProfile: monthly ? FixColumnProfile.columnProfileDateMonthDays : FixColumnProfile.columnProfileDateWeekdays,
                lineCount: data.length,
                gridCellBuilder: pixelCellBuilder.gridCellBuilder,
                lineHeight: Pixel.pixelHeight,
                useFixedFirstColumn: true,
                bottomScrollExtend: seriesDataViewOverlays.bottomHeight,
              ),
            ),
          ],
        );
      },
    );
  }
}
