import 'package:flutter/material.dart';

import '../../../../../../model/column_profile/fix_column_profile.dart';
import '../../../../../../model/series/data/daily_life/daily_life_value.dart';
import '../../../../../../model/series/data/series_data_filter.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../model/series/settings/daily_life/daily_life_attribute_resolver.dart';
import '../../../../../controls/grid/daily/day/daily_life_day_item.dart';
import '../../../../../controls/grid/daily/pixel.dart';
import '../../../../../controls/grid/daily/pixel_cell_builder.dart';
import '../../../../../controls/grid/daily/row/row_item.dart';
import '../../../../../controls/grid/two_dimensional_scrollable_table.dart';
import '../../series_data_no_data.dart';
import '../../series_data_view_overlays.dart';

class SeriesDataDailyLifePixelsView extends StatelessWidget {
  final List<DailyLifeValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;
  final SeriesDataFilter seriesDataFilter;
  final SeriesDataViewOverlays seriesDataViewOverlays;

  const SeriesDataDailyLifePixelsView(
      {super.key, required this.seriesViewMetaData, required this.seriesData, required this.seriesDataFilter, required this.seriesDataViewOverlays});

  @override
  Widget build(BuildContext context) {
    DailyLifeAttributeResolver dailyLifeAttributeResolver = DailyLifeAttributeResolver(seriesViewMetaData.seriesDef);
    Pixel.updatePixelStyles(context);

    /// from new to old (latest date is the first item)
    List<DailyLifeDayItem> allDayItems = DailyLifeDayItem.buildDayItems(seriesData, seriesViewMetaData.seriesDef);
    var dayItems = allDayItems.where((dayItem) => seriesDataFilter.filterDate(dayItem.dayDate)).toList();

    if (dayItems.isEmpty || dayItems.where((i) => i.count > 0).isEmpty) {
      return SeriesDataNoData(
        seriesViewMetaData: seriesViewMetaData,
        noDataBecauseOfFilter: true,
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool monthly = constraints.maxWidth > FixColumnProfile.columnProfileDateMonthDays.minWidthScaled();

        List<RowItem<DailyLifeDayItem>> data = monthly ? RowItem.buildMonthRowItems(dayItems) : RowItem.buildWeekRowItems(dayItems);

        var pixelCellBuilder = PixelCellBuilder(
          data: data,
          monthly: monthly,
          gridCellChildBuilder: (DailyLifeDayItem dayItem) {
            return dayItem.toPixel(
              monthly,
              dailyLifeAttributeResolver,
            );
          },
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
                tableColumnProfile: monthly ? FixColumnProfile.columnProfileDateMonthDays : FixColumnProfile.columnProfileDateWeekdays,
                lineCount: data.length,
                gridCellBuilder: pixelCellBuilder.gridCellBuilder,
                lineHeight: Pixel.pixelHeight,
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
