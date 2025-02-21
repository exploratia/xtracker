import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../model/series/data/blood_pressure/blood_pressure_value.dart';
import '../../../../../../model/series/data/series_data.dart';
import '../../../../../../model/series/profile/table_column_profile.dart';
import '../../../../../../model/series/series_view_meta_data.dart';
import '../../../../../../util/date_time_utils.dart';
import '../../../../../../util/table_utils.dart';
import '../../../../../layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../../../navigation/hide_bottom_navigation_bar.dart';
import '../../../../../responsive/device_dependent_constrained_box.dart';
import 'blood_pressure_values_renderer.dart';

class SeriesDataBloodPressureTableView extends StatelessWidget {
  const SeriesDataBloodPressureTableView({super.key, required this.seriesViewMetaData, required this.seriesData});

  final SeriesData<BloodPressureValue> seriesData;
  final SeriesViewMetaData seriesViewMetaData;

  @override
  Widget build(BuildContext context) {
    final TableColumnProfile tableColumnProfile = TableColumnProfile(columns: [
      TableColumn(minWidth: 80),
      TableColumn(minWidth: 80),
      TableColumn(minWidth: 80),
      TableColumn(minWidth: 80),
    ]);

    final themeData = Theme.of(context);
// TODO seriesViewMetaData.editMode => klick on Renderer
    final t = AppLocalizations.of(context)!;
    // TODO Anhand Breite (zu schmal) fesetlegen, ob Titel in AppBar oder hier in der View anzgeiezt werdne muss
    // TODO immer nur Diagrammsicht / Tabelle und immer Icon + Name als erstes in der View?
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // TEST 2D

        if (constraints.maxWidth < 320) {
          return const Text("TODO 2d grid view");
        } else {
          return SingleChildScrollViewWithScrollbar(
            scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
            child: SizedBox(
              width: min(DeviceDependentWidthConstrainedBox.tabletMaxWidth, constraints.maxWidth),
              child: Table(
                // https://api.flutter.dev/flutter/widgets/Table-class.html
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(80),
                  // 0: IntrinsicColumnWidth(),
                  // 0: FlexColumnWidth(),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                },
                border: const TableBorder.symmetric(
                  inside: BorderSide(width: 1, color: Colors.black12),
                ),
                children: _buildTableRows(t, themeData),
              ),
            ),
          );
        }
      },
    );
  }

  List<TableRow> _buildTableRows(AppLocalizations t, ThemeData themeData) {
    var data = _buildTableDataProvider(seriesData);
    List<TableRow> rows = [
      TableUtils.tableHeadline(
        [
          const _TableHeadline(
            text: 'Datum',
            textAlign: TextAlign.left,
          ),
          _TableHeadline(text: 'Morgens ${t.seriesDataTitle}'),
          const _TableHeadline(text: 'Mittags'),
          const _TableHeadline(text: 'Abends'),
        ],
        cellPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: themeData.textTheme.bodyMedium?.color ?? Colors.grey,
              width: 1,
            ),
          ),
        ),
      ),
    ];
    rows.addAll(data.map((e) => e.toTableRow()));
    return rows;
  }

  List<_BloodPressureDayItem> _buildTableDataProvider(SeriesData<BloodPressureValue> seriesData) {
    List<_BloodPressureDayItem> list = [];
    const tableItemSaturdayColor = Color.fromRGBO(128, 128, 128, 0.1);
    const tableItemSundayColor = Color.fromRGBO(128, 128, 128, 0.2);

    _BloodPressureDayItem? actItem;

    for (var item in seriesData.seriesItems) {
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

  TableRow toTableRow() {
    BoxDecoration? boxDecoration;
    if (backgroundColor != null) {
      boxDecoration = BoxDecoration(color: backgroundColor);
    }
    return TableUtils.tableRow(
      [
        date,
        BloodPressureValuesRenderer(bloodPressureValues: morning),
        BloodPressureValuesRenderer(bloodPressureValues: midday),
        BloodPressureValuesRenderer(bloodPressureValues: evening),
      ],
      decoration: boxDecoration,
    );
  }
}

class _TableHeadline extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const _TableHeadline({required this.text, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
