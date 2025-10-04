import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profile.dart';
import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../controls/grid/row_per_day/day_row_item.dart';
import '../../../../../controls/grid/row_per_day/row_per_day_cell_builder.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';
import 'blood_pressure_value_renderer.dart';

class SeriesDataBloodPressureTableView extends StatelessWidget {
  final List<BloodPressureValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  const SeriesDataBloodPressureTableView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

  @override
  Widget build(BuildContext context) {
    FixColumnProfile columnProfile = seriesViewMetaData.tableFixColumnProfile!;

    var filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
    if (filteredSeriesData.isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    List<DayRowItem<BloodPressureValue>> data = DayRowItem.buildTableDataProvider(seriesViewMetaData, filteredSeriesData);

    var rowPerDayCellBuilder = RowPerDayCellBuilder<BloodPressureValue>(
      data: data,
      fixColumnProfile: columnProfile,
      gridCellChildBuilder: (BloodPressureValue value, Size _) => BloodPressureValueRenderer(
        bloodPressureValue: value,
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
            tableColumnProfile: columnProfile,
            lineCount: data.length,
            gridCellBuilder: rowPerDayCellBuilder.gridCellBuilder,
            lineHeight: BloodPressureValueRenderer.height,
            useFixedFirstColumn: true,
            bottomScrollExtend: seriesDataViewOverlays.bottomHeight,
          ),
        ),
      ],
    );
  }
}
