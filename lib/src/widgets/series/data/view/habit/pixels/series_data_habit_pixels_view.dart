import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profiles.dart';
import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/grid/daily/day/habit_day_item.dart';
import '../../../../../controls/grid/daily/pixel.dart';
import '../../../../../controls/grid/daily/row/row_item.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';

class SeriesDataHabitPixelsView extends StatelessWidget {
  final SeriesData<HabitValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;

  const SeriesDataHabitPixelsView({super.key, required this.seriesViewMetaData, required this.seriesData});

  @override
  Widget build(BuildContext context) {
    Pixel.updatePixelStyles(context);
    var dayItems = HabitDayItem.buildDayItems(seriesData, seriesViewMetaData.seriesDef);

    // determine max (min always 1)
    const minVal = 1;
    int maxVal = dayItems.map((e) => e.count).reduce((soFarMax, count) => max(soFarMax, count));
    Color baseColor = seriesViewMetaData.seriesDef.color;
    var displaySettings = seriesViewMetaData.seriesDef.displaySettingsReadonly();
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

          return TwoDimensionalScrollableTable(
            tableColumnProfile: monthly ? FixColumnProfiles.columnProfileDateMonthDays : FixColumnProfiles.columnProfileDateWeekdays,
            lineCount: data.length,
            gridCellBuilder: gridCellBuilder,
            lineHeight: Pixel.pixelHeight,
            useFixedFirstColumn: true,
          );
        },
      ),
    );
  }
}
