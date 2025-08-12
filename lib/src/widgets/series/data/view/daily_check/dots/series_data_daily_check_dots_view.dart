import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profiles.dart';
import '../../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/grid/daily/day/daily_check_day_item.dart';
import '../../../../../controls/grid/daily/dot.dart';
import '../../../../../controls/grid/daily/row/row_item.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';

class SeriesDataDailyCheckDotsView extends StatelessWidget {
  final SeriesData<DailyCheckValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;

  const SeriesDataDailyCheckDotsView({super.key, required this.seriesViewMetaData, required this.seriesData});

  @override
  Widget build(BuildContext context) {
    Dot.updateDotStyles(context);
    DailyCheckDayItem.updateValuesFromSeries(seriesViewMetaData.seriesDef);
    var dayItems = DailyCheckDayItem.buildDayItems(seriesData);

    // padding because of headline in stack
    return Padding(
      padding: const EdgeInsets.only(top: ThemeUtils.seriesDataViewTopPadding),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          bool monthly = constraints.maxWidth > FixColumnProfiles.columnProfileDateMonthDays.minWidth();

          List<RowItem<DailyCheckDayItem>> data = monthly ? RowItem.buildMonthRowItems(dayItems) : RowItem.buildWeekRowItems(dayItems);

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
              backgroundColor: dayItem.backgroundColor,
              child: dayItem.toDot(monthly),
            );
          }

          return TwoDimensionalScrollableTable(
            tableColumnProfile: monthly ? FixColumnProfiles.columnProfileDateMonthDays : FixColumnProfiles.columnProfileDateWeekdays,
            lineCount: data.length,
            gridCellBuilder: gridCellBuilder,
            lineHeight: Dot.dotHeight,
            useFixedFirstColumn: true,
          );
        },
      ),
    );
  }
}
