import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profile.dart';
import '../../../../../../model/series/data/free/multi_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../controls/grid/row_per_day/day_row_item.dart';
import '../../../../../controls/grid/row_per_day/row_per_day_cell_builder.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';
import 'multi_value_renderer.dart';

abstract class SeriesDataMultiValueTableView<V extends MultiValue> extends StatelessWidget {
  final List<V> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  const SeriesDataMultiValueTableView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

  @override
  Widget build(BuildContext context) {
    FixColumnProfile columnProfile = FixColumnProfile.columnProfileDateTimeValue;

    var filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
    if (filteredSeriesData.isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    int lineCount = 0;
    GridCell Function(BuildContext context, int yIndex, int xIndex, Size cellSize) gridCellBuilder =
        (context, yIndex, xIndex, cellSize) => GridCell(child: Container());

    {
      List<DayRowItem<V>> data = DayRowItem.buildTableDataProvider(seriesViewMetaData, filteredSeriesData);

      var builder = RowPerDayCellBuilder<V>(
        data: data,
        fixColumnProfile: columnProfile,
        gridCellChildBuilder: (V value, Size _) => MultiValueRenderer(
          multiValue: value,
          seriesDef: seriesViewMetaData.seriesDef,
          editMode: seriesViewMetaData.editMode,
          wrapWithDateTimeTooltip: true,
        ),
      );
      lineCount = data.length;
      gridCellBuilder = builder.gridCellBuilder;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        seriesDataViewOverlays.buildTopSpacer(),
        Expanded(
          child: TwoDimensionalScrollableTable(
            tableColumnProfile: columnProfile,
            lineCount: lineCount,
            gridCellBuilder: gridCellBuilder,
            lineHeight: MultiValueRenderer.height,
            useFixedFirstColumn: true,
            bottomScrollExtend: seriesDataViewOverlays.bottomHeight,
          ),
        ),
      ],
    );
  }
}
