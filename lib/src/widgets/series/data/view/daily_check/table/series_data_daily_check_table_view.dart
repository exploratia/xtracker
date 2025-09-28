import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profile.dart';
import '../../../../../../model/series/data/daily_check/daily_check_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../controls/grid/row_per_day/day_row_item.dart';
import '../../../../../controls/grid/row_per_day/row_per_day_cell_builder.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';
import 'daily_check_value_renderer.dart';

class SeriesDataDailyCheckTableView extends StatelessWidget {
  final List<DailyCheckValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  const SeriesDataDailyCheckTableView(
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

    List<DayRowItem<DailyCheckValue>> data = DayRowItem.buildTableDataProvider(seriesViewMetaData, filteredSeriesData);

    var rowPerDayCellBuilder = RowPerDayCellBuilder<DailyCheckValue>(
      data: data,
      useDateTimeValueColumnProfile: useDateTimeValueColumnProfile,
      gridCellChildBuilder: (DailyCheckValue value, Size _) => DailyCheckValueRenderer(
        dailyCheckValue: value,
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
            lineHeight: DailyCheckValueRenderer.height,
            useFixedFirstColumn: true,
            bottomScrollExtend: seriesDataViewOverlays.bottomHeight,
          ),
        ),
      ],
    );
  }
}
