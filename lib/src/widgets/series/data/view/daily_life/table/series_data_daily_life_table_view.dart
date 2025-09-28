import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profile.dart';
import '../../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../model/series/settings/daily_life/daily_life_attribute_resolver.dart';
import '../../../../../controls/grid/row_per_day/day_row_item.dart';
import '../../../../../controls/grid/row_per_day/row_per_day_cell_builder.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';
import 'daily_life_value_renderer.dart';

class SeriesDataDailyLifeTableView extends StatelessWidget {
  final List<DailyLifeValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  const SeriesDataDailyLifeTableView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

  @override
  Widget build(BuildContext context) {
    var dailyLifeAttributeResolver = DailyLifeAttributeResolver(seriesViewMetaData.seriesDef);
    var filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
    if (filteredSeriesData.isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    List<DayRowItem<DailyLifeValue>> data = DayRowItem.buildTableDataProvider(seriesViewMetaData, filteredSeriesData);

    var rowPerDayCellBuilder = RowPerDayCellBuilder<DailyLifeValue>(
      data: data,
      useDateTimeValueColumnProfile: true,
      gridCellChildBuilder: (DailyLifeValue value, Size cellSize) => DailyLifeValueRenderer(
        dailyLifeValue: value,
        seriesDef: seriesViewMetaData.seriesDef,
        editMode: seriesViewMetaData.editMode,
        // wrapWithDateTimeTooltip: true, // tooltip not required in date time value column profile
        dailyLifeAttributeResolver: dailyLifeAttributeResolver,
        maxContentWidth: cellSize.width,
      ),
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
            tableColumnProfile: FixColumnProfile.columnProfileDateTimeValue,
            lineCount: data.length,
            gridCellBuilder: rowPerDayCellBuilder.gridCellBuilder,
            lineHeight: DailyLifeValueRenderer.height,
            useFixedFirstColumn: true,
            bottomScrollExtend: seriesDataViewOverlays.bottomHeight,
          ),
        ),
      ],
    );
  }
}
