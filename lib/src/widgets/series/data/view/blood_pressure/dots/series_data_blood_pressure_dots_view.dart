import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profile.dart';
import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../controls/grid/daily/day/blood_pressure_day_item.dart';
import '../../../../../controls/grid/daily/dot.dart';
import '../../../../../controls/grid/daily/dot_cell_builder.dart';
import '../../../../../controls/grid/daily/row/row_item.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';

class SeriesDataBloodPressureDotsView extends StatelessWidget {
  final List<BloodPressureValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  const SeriesDataBloodPressureDotsView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

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
        bool monthly = constraints.maxWidth > FixColumnProfile.columnProfileDateMonthDays.minWidthScaled();

        List<RowItem<BloodPressureDayItem>> data = monthly ? RowItem.buildMonthRowItems(dayItems) : RowItem.buildWeekRowItems(dayItems);

        var dotCellBuilder = DotCellBuilder(data: data, monthly: monthly, gridCellChildBuilder: (dayItem) => dayItem.toDot(monthly));

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
                gridCellBuilder: dotCellBuilder.gridCellBuilder,
                lineHeight: Dot.dotHeight,
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
