import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/column_profile.dart';
import '../../../../../../model/column_profile/column_type.dart';
import '../../../../../../model/series/tags/tag_resolver.dart';
import '../../../../../../model/series/data/custom/custom_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/logging/flutter_simple_logging.dart';
import '../../../../../../util/number_utils.dart';
import '../../../../../controls/tag/tag_renderer.dart';
import '../../../../../controls/grid/series/series_data_value_cell_builder.dart';
import '../../../../../controls/grid/series/series_data_value_grid_item.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../../../../controls/text/overflow_text.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';
import 'custom_value_renderer.dart';

class SeriesDataCustomTableView extends StatelessWidget {
  final List<CustomValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  const SeriesDataCustomTableView({
    super.key,
    required this.seriesViewMetaData,
    required this.seriesData,
    required this.seriesDataFilter,
    required this.seriesDataViewOverlays,
  });

  @override
  Widget build(BuildContext context) {
    ColumnProfile columnProfile = seriesViewMetaData.columnProfile!;
    var tagResolver = TagResolver(seriesViewMetaData.seriesDef);

    var filteredSeriesData = seriesData.where((value) => seriesDataFilter.filter(value)).toList();
    if (filteredSeriesData.isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    GridCell Function(BuildContext context, int yIndex, int xIndex, Size cellSize) gridCellBuilder = SeriesDataValueCellBuilder(
      data: SeriesDataValueGridItem.buildTableDataProvider(seriesViewMetaData, filteredSeriesData, context),
      columnProfile: columnProfile,
      editMode: seriesViewMetaData.editMode,
      gridCellChildBuilder: (value, cellSize, columnDef) {
        if (columnDef.siid != null) {
          var val = value.values[columnDef.siid];
          if (val == null || val.isNaN) {
            return const Center(child: Text("-"));
          }
          return Center(child: OverflowText(expanded: false, NumberUtils.formatNumber(val)));
        } else if (columnDef.columnType == ColumnType.tag) {
          if (value.tagId != null) {
            var tag = tagResolver.resolve(value.tagId);
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TagRenderer(tag: tag),
              ),
            );
          } else {
            return const Center(child: Text("-"));
          }
        }

        // Fallback
        SimpleLogging.w("Unexpected call to gridCellBuilder in SeriesDataValueCellBuilder!");
        return Container(height: 2, width: 2, color: Colors.red);
      },
    ).gridCellBuilder;

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
            lineCount: filteredSeriesData.length,
            gridCellBuilder: gridCellBuilder,
            lineHeight: CustomValueRenderer.height,
            useFixedFirstColumn: true,
            bottomScrollExtend: seriesDataViewOverlays.bottomHeight,
          ),
        ),
      ],
    );
  }
}
