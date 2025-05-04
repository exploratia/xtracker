import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/profile/fix_table_column_profiles.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/globals.dart';
import '../../../../../../util/theme_utils.dart';
import '../../../../../grid/two_dimensional_scrollable_table.dart';
import 'blood_pressure_values_renderer.dart';

class SeriesDataBloodPressureTableView extends StatelessWidget {
  final SeriesData<BloodPressureValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;

  const SeriesDataBloodPressureTableView({super.key, required this.seriesViewMetaData, required this.seriesData});

  @override
  Widget build(BuildContext context) {
    // for blood pressure we need a special TableColumnProfile

    List<_BloodPressureDayItem> data = _buildTableDataProvider(seriesData);
    // calc line height = single line height * max lines per day of all items
    var maxItemsPerDayPart = data.fold(
      1,
      (previousValue, item) {
        var maxItems = math.max(math.max(item.morning.length, item.midday.length), item.evening.length);
        return math.max(previousValue, maxItems);
      },
    );
    int lineHeight = 26 * maxItemsPerDayPart;

    gridCellBuilder(BuildContext context, int yIndex, int xIndex) {
      _BloodPressureDayItem bloodPressureDayItem = data[yIndex];

      if (xIndex == 0) {
        return GridCell(backgroundColor: bloodPressureDayItem.backgroundColor, child: Center(child: Text(bloodPressureDayItem.date)));
      }

      List<BloodPressureValue> bloodPressureValues;
      if (xIndex == 1) {
        bloodPressureValues = bloodPressureDayItem.morning;
      } else if (xIndex == 2) {
        bloodPressureValues = bloodPressureDayItem.midday;
      } else {
        bloodPressureValues = bloodPressureDayItem.evening;
      }
      return GridCell(
        backgroundColor: bloodPressureDayItem.backgroundColor,
        child: BloodPressureValuesRenderer(
          bloodPressureValues: bloodPressureValues,
          seriesViewMetaData: seriesViewMetaData,
        ),
      );
    }

    // padding because of headline in stack
    return Padding(
      padding: const EdgeInsets.only(top: ThemeUtils.seriesDataViewTopPadding),
      child: TwoDimensionalScrollableTable(
        tableColumnProfile: FixTableColumnProfiles.tableColumnProfileDateMorningMiddayEvening,
        lineCount: data.length,
        gridCellBuilder: gridCellBuilder,
        lineHeight: lineHeight,
        useFixedFirstColumn: true,
      ),
    );
  }

  List<_BloodPressureDayItem> _buildTableDataProvider(SeriesData<BloodPressureValue> seriesData) {
    List<_BloodPressureDayItem> list = [];
    _BloodPressureDayItem? actItem;

    for (var item in seriesData.data.reversed) {
      String dateDay = DateTimeUtils.formateDate(item.dateTime);
      if (actItem == null || actItem.date != dateDay) {
        if (actItem != null) {
          list.add(actItem);
        }
        Color? backgroundColor;
        if (item.dateTime.weekday == DateTime.sunday) {
          backgroundColor = Globals.backgroundColorSunday;
        } else if (item.dateTime.weekday == DateTime.saturday) {
          backgroundColor = Globals.backgroundColorSaturday;
        }
        actItem = _BloodPressureDayItem(dateDay, backgroundColor);
      }

      if (item.dateTime.hour < 10) {
        actItem.morning.add(item);
      } else if (item.dateTime.hour > 16) {
        actItem.evening.add(item);
      } else {
        actItem.midday.add(item);
      }
    }

    // add last item to list
    if (actItem != null) {
      list.add(actItem);
    }

    return list;
  }
}

class _BloodPressureDayItem {
  final String date;
  final Color? backgroundColor;
  List<BloodPressureValue> morning = [];
  List<BloodPressureValue> midday = [];
  List<BloodPressureValue> evening = [];

  _BloodPressureDayItem(this.date, this.backgroundColor);
}
