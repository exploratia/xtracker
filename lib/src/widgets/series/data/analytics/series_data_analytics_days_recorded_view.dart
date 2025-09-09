import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/locale_keys.g.dart';
import '../../../../model/series/data/datetime_item.dart';
import '../../../../model/series/data/series_data_value.dart';
import '../../../../model/series/series_view_meta_data.dart';
import '../../../../util/date_time_utils.dart';
import '../../../../util/day_item/day_item.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/table_utils.dart';
import '../../../../util/theme_utils.dart';
import '../../../controls/card/settings_card.dart';
import '../../../controls/layout/h_centered_scroll_view.dart';
import '../../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../../controls/progress/progress_bar.dart';
import '../../../controls/text/overflow_text.dart';

class SeriesDataAnalyticsDaysRecordedView extends StatelessWidget {
  static const int _allDays = -1;
  static const List<int> _dataBasisDays = [7, 30, 90, 365, _allDays];

  const SeriesDataAnalyticsDaysRecordedView({super.key, required this.seriesViewMetaData, required this.seriesDataValues});

  final SeriesViewMetaData seriesViewMetaData;
  final List<SeriesDataValue> seriesDataValues;

  @override
  Widget build(BuildContext context) {
    // determine all time max value (for correct max pixel color)
    var dayItems = DayItem.buildDayItems(seriesDataValues, (day) => DayItem(day));

    List<TableRow> rows = _AnalysisTable.buildKeyValueTableRows(context);

    var daysRecordedList = _dataBasisDays.map((lastXDays) => _DaysRecorded.analyse(dayItems, lastXDays));

    for (var daysRecorded in daysRecordedList) {
      var keyColumnText = LocaleKeys.seriesDataAnalytics_label_lastXDays.tr(args: [daysRecorded.dataBasisDays.toString()]);
      if (daysRecorded.dataBasisDays == _allDays) {
        keyColumnText = LocaleKeys.seriesDataAnalytics_label_total.tr();
      }
      var keyColumnWidget = Text(
        keyColumnText,
        softWrap: false,
      );

      var valueColumnWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProgressBar(
            value: daysRecorded.percentage,
            color: seriesViewMetaData.seriesDef.color,
            padding: const EdgeInsets.only(
              top: ThemeUtils.verticalSpacingSmall,
              bottom: ThemeUtils.verticalSpacingSmall,
              left: ThemeUtils.horizontalSpacing,
            ),
          ),
          Row(
            spacing: ThemeUtils.horizontalSpacingLarge,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                child: Align(
                  alignment: AlignmentGeometry.centerRight,
                  child: Text(daysRecorded.percentageTo100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: ThemeUtils.defaultPadding),
                child: Text(daysRecorded.absoluteRate),
              ),
            ],
          ),
        ],
      );

      rows.add(
        TableUtils.tableRow(
          [
            keyColumnWidget,
            valueColumnWidget,
          ],
        ),
      );
    }

    Widget table = _AnalysisTable(rows: rows);

    return TrendViewSettingsCard(trendInfoDialogContent: const _DaysRecordedInfoDialogContent(), children: [
      table,
    ]);
  }
}

class TrendViewSettingsCard extends StatelessWidget {
  const TrendViewSettingsCard({
    super.key,
    required this.trendInfoDialogContent,
    required this.children,
  });

  final Widget trendInfoDialogContent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: Row(
        spacing: ThemeUtils.horizontalSpacing,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OverflowText(
            LocaleKeys.seriesDataAnalytics_recordedDays_title.tr(),
            style: Theme.of(context).textTheme.titleLarge,
            expanded: false,
            flexible: true,
          ),
          IconButton(
            tooltip: LocaleKeys.commons_btn_info_tooltip.tr(),
            onPressed: () => Dialogs.simpleOkDialog(
              SingleChildScrollViewWithScrollbar(
                useHorizontalScreenPaddingForScrollbar: true,
                child: trendInfoDialogContent,
              ),
              context,
              title: LocaleKeys.seriesDataAnalytics_recordedDays_title.tr(),
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      children: children,
    );
  }
}

class _DaysRecordedInfoDialogContent extends StatelessWidget {
  const _DaysRecordedInfoDialogContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: ThemeUtils.verticalSpacingLarge,
      children: [
        Text(LocaleKeys.seriesDataAnalytics_recordedDays_label_recordedDaysInfo.tr()),
      ],
    );
  }
}

class _AnalysisTable extends StatelessWidget {
  const _AnalysisTable({
    required this.rows,
  });

  final List<TableRow> rows;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => HCenteredScrollView(
        children: [
          Table(
            columnWidths: <int, TableColumnWidth>{
              0: const FixedColumnWidth(120),
              1: FixedColumnWidth(math.max(120, constraints.maxWidth - 120)),
            },
            border: TableBorder.symmetric(
              inside: BorderSide(width: 1, color: themeData.canvasColor),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows,
          ),
        ],
      ),
    );
  }

  static List<TableRow> buildKeyValueTableRows(BuildContext context) {
    List<TableRow> rows = TableUtils.buildKeyValueTableRows(
      context,
      keyColumnTitle: LocaleKeys.seriesDataAnalytics_label_dataset.tr(),
      valueColumnTitle: LocaleKeys.seriesDataAnalytics_recordedDays_label_ratio.tr(),
    );
    return rows;
  }
}

class _DaysRecorded {
  final int dataBasisDays;
  final int countedDays;
  final int recordedDays;

  _DaysRecorded(this.dataBasisDays, this.countedDays, this.recordedDays);

  double get percentage {
    return recordedDays.toDouble() / countedDays.toDouble();
  }

  String get percentageTo100 {
    return "${(recordedDays.toDouble() / countedDays.toDouble() * 100.0).toInt()}%";
  }

  String get absoluteRate {
    return "$recordedDays / $countedDays";
  }

  static _DaysRecorded analyse(List<DayItem<DateTimeItem>> dayItems, int dataBasisDays) {
    // special case all
    if (dataBasisDays == SeriesDataAnalyticsDaysRecordedView._allDays) {
      return _DaysRecorded(dataBasisDays, dayItems.length, dayItems.where((di) => di.count > 1).length);
    }

    var dateFilter = DateTimeUtils.truncateToDay(DateTimeUtils.truncateToDay(DateTime.now()).subtract(Duration(days: dataBasisDays - 1, microseconds: 1)));
    var dateFiltered = dayItems.where((di) => di.dayDate.isAfter(dateFilter)).toList();
    var recordedDays = dateFiltered.where((di) => di.count >= 1).length;
    return _DaysRecorded(dataBasisDays, dateFiltered.length, recordedDays);
  }
}
