import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profile.dart';
import '../../../../../../model/series/data/habit/habit_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../controls/grid/row_per_day/day_row_item.dart';
import '../../../../../controls/grid/row_per_day/row_per_day_cell_builder.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';
import 'habit_value_renderer.dart';

class SeriesDataHabitTableView extends StatelessWidget {
  final List<HabitValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  const SeriesDataHabitTableView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

  @override
  Widget build(BuildContext context) {
    bool useDateTimeValueColumnProfile = seriesViewMetaData.seriesDef.displaySettingsReadonly().tableViewUseColumnProfileDateTimeValue;

    var filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
    if (filteredSeriesData.isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    List<DayRowItem<HabitValue>> data = DayRowItem.buildTableDataProvider(seriesViewMetaData, filteredSeriesData);

    var rowPerDayCellBuilder = RowPerDayCellBuilder<HabitValue>(
      data: data,
      useDateTimeValueColumnProfile: useDateTimeValueColumnProfile,
      gridCellChildBuilder: (HabitValue value, Size _) => HabitValueRenderer(
        habitValue: value,
        seriesDef: seriesViewMetaData.seriesDef,
        editMode: seriesViewMetaData.editMode,
        wrapWithDateTimeTooltip: true,
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
            tableColumnProfile:
                useDateTimeValueColumnProfile ? FixColumnProfile.columnProfileDateTimeValue : FixColumnProfile.columnProfileDateMorningMiddayEvening,
            lineCount: data.length,
            gridCellBuilder: rowPerDayCellBuilder.gridCellBuilder,
            lineHeight: HabitValueRenderer.height,
            useFixedFirstColumn: true,
            bottomScrollExtend: seriesDataViewOverlays.bottomHeight,
          ),
        ),
      ],
    );
  }
}
