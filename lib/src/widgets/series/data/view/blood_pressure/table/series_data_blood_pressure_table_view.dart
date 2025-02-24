import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/profile/table_column_profile.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../grid/two_dimensional_scrollable_table.dart';
import 'blood_pressure_values_renderer.dart';

class SeriesDataBloodPressureTableView extends StatelessWidget {
  static final TableColumnProfile _tableColumnProfile = TableColumnProfile(columns: [
    TableColumn(minWidth: 80, title: '-', msgId: 'bloodPressureTableColumnTitleDate'),
    TableColumn(minWidth: 80, title: '-', msgId: 'bloodPressureTableColumnTitleMorning'),
    TableColumn(minWidth: 80, title: '-', msgId: 'bloodPressureTableColumnTitleMidday'),
    TableColumn(minWidth: 80, title: '-', msgId: 'bloodPressureTableColumnTitleEvening'),
  ]);

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

    // TODO Anhand Breite (zu schmal) fesetlegen, ob Titel in AppBar oder hier in der View anzgeiezt werdne muss
    // TODO immer nur Titel Diagrammsicht / Tabelle / Dots und immer Icon + Name als erstes in der View?
    // TODO im Titel immer nur Serien-Icon + Anzeige-Typ-Icon in gleicher Farbe -> in View dann als Headline der SerienName

    return TwoDimensionalScrollableTable(
      tableColumnProfile: _tableColumnProfile,
      lineCount: data.length,
      gridCellBuilder: gridCellBuilder,
      lineHeight: lineHeight,
    );
  }

  List<_BloodPressureDayItem> _buildTableDataProvider(SeriesData<BloodPressureValue> seriesData) {
    List<_BloodPressureDayItem> list = [];
    const tableItemSaturdayColor = Color.fromRGBO(128, 128, 128, 0.1);
    const tableItemSundayColor = Color.fromRGBO(128, 128, 128, 0.2);

    _BloodPressureDayItem? actItem;

    for (var item in seriesData.seriesItems.reversed) {
      String dateDay = DateTimeUtils.formateDate(item.dateTime);
      if (actItem == null || actItem.date != dateDay) {
        if (actItem != null) {
          list.add(actItem);
        }
        Color? backgroundColor;
        if (item.dateTime.weekday == DateTime.sunday) {
          backgroundColor = tableItemSundayColor;
        } else if (item.dateTime.weekday == DateTime.saturday) {
          backgroundColor = tableItemSaturdayColor;
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
