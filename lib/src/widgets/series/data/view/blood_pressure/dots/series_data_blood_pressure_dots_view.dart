import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profiles.dart';
import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../controls/grid/daily/day/blood_pressure_day_item.dart';
import '../../../../../controls/grid/daily/dot.dart';
import '../../../../../controls/grid/daily/row/row_item.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../series_data_no_data.dart';

class SeriesDataBloodPressureDotsView extends StatelessWidget {
  final List<BloodPressureValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;

  const SeriesDataBloodPressureDotsView({super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter});

  @override
  Widget build(BuildContext context) {
    Dot.updateDotStyles(context);
    BloodPressureDayItem.updateValuesFromSeries(seriesViewMetaData.seriesDef);

    var filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
    if (filteredSeriesData.isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    var dayItems = BloodPressureDayItem.buildDayItems(filteredSeriesData, seriesViewMetaData.seriesDef);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool monthly = constraints.maxWidth > FixColumnProfiles.columnProfileDateMonthDays.minWidth();

        List<RowItem<BloodPressureDayItem>> data = monthly ? RowItem.buildMonthRowItems(dayItems) : RowItem.buildWeekRowItems(dayItems);

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
          bottomScrollExtend: ThemeUtils.seriesDataBottomFilterViewHeight,
        );
      },
    );
  }
}
