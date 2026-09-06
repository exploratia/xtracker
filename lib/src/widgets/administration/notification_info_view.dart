import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/series/series_def.dart';
import '../../util/app_series_notifications.dart';
import '../../util/date_time_utils.dart';
import '../../util/table_utils.dart';
import '../../util/theme_utils.dart';
import '../controls/card/settings_card.dart';
import '../controls/layout/scroll_footer.dart';
import '../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../controls/navigation/hide_bottom_navigation_bar.dart';

class NotificationInfoView extends StatelessWidget {
  final List<SeriesDef> series;
  final Future<void> Function()? onRefreshCallback;

  const NotificationInfoView({super.key, required this.series, this.onRefreshCallback});

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var enabledSeries = series.where((seriesDef) => seriesDef.notificationSettingsReadonly().enabled).toList();

    return SingleChildScrollViewWithScrollbar(
      useScreenPadding: true,
      onRefreshCallback: onRefreshCallback,
      scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
      child: Column(
        spacing: ThemeUtils.screenPadding,
        children: [
          SettingsCard.singleEntry(
            title: LocaleKeys.notificationInfo_section_nextNotifications.tr(),
            showDivider: true,
            content: enabledSeries.isEmpty
                ? _EmptyInfo(LocaleKeys.notificationInfo_label_noEnabledNotifications.tr())
                : _buildSummaryTable(context, enabledSeries, now),
          ),
          ...enabledSeries.map(
            (seriesDef) => SettingsCard.singleEntry(
              title: seriesDef.name,
              showDivider: true,
              content: _buildSeriesScheduleTable(context, seriesDef, now),
            ),
          ),
          const ScrollFooter(),
        ],
      ),
    );
  }

  Widget _buildSummaryTable(BuildContext context, List<SeriesDef> enabledSeries, DateTime now) {
    var rows = [
      TableUtils.tableHeadline(
        [
          LocaleKeys.notificationInfo_table_column_series.tr(),
          LocaleKeys.notificationInfo_table_column_nextNotification.tr(),
        ],
        themeData: Theme.of(context),
      ),
    ];

    for (var seriesDef in enabledSeries) {
      var nextNotification = AppSeriesNotifications.nextScheduledNotificationAt(seriesDef, now: now);
      rows.add(
        TableUtils.tableRow(
          [
            seriesDef.name,
            nextNotification == null ? '-' : _formatReminderDuration(context, nextNotification.difference(now)),
          ],
        ),
      );
    }

    return _InfoTable(
      rows: rows,
      columnWidthsBuilder: _summaryColumnWidths,
    );
  }

  Widget _buildSeriesScheduleTable(BuildContext context, SeriesDef seriesDef, DateTime now) {
    var notifications = AppSeriesNotifications.scheduledNotificationTimes(seriesDef, now: now);
    if (notifications.isEmpty) {
      return _EmptyInfo(LocaleKeys.notificationInfo_label_noScheduledNotifications.tr());
    }

    var rows = [
      TableUtils.tableHeadline(
        [
          '#',
          LocaleKeys.notificationInfo_table_column_notification.tr(),
        ],
        themeData: Theme.of(context),
      ),
      ...notifications.indexed.map(
        (entry) => TableUtils.tableRow(
          [
            entry.$1 + 1,
            _formatAbsoluteDateTime(entry.$2),
          ],
        ),
      ),
    ];

    return _InfoTable(
      rows: rows,
      columnWidthsBuilder: (_) => const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
    );
  }

  Map<int, TableColumnWidth> _summaryColumnWidths(BoxConstraints constraints) {
    if (constraints.maxWidth < 260) {
      return <int, TableColumnWidth>{
        0: FixedColumnWidth(constraints.maxWidth / 2),
        1: const FlexColumnWidth(),
      };
    }

    return <int, TableColumnWidth>{
      0: FixedColumnWidth(constraints.maxWidth / 3),
      1: const FlexColumnWidth(),
    };
  }

  String _formatAbsoluteDateTime(DateTime dateTime) {
    return '${DateTimeUtils.formatDateWithDay(dateTime)} ${DateTimeUtils.formatTime(dateTime)}';
  }

  String _formatReminderDuration(BuildContext context, Duration duration) {
    var totalMinutes = duration.inSeconds <= 0 ? 0 : (duration.inSeconds + Duration.secondsPerMinute - 1) ~/ Duration.secondsPerMinute;
    if (totalMinutes <= 0) {
      totalMinutes = 1;
    }

    const minutesPerDay = Duration.hoursPerDay * Duration.minutesPerHour;
    var days = totalMinutes ~/ minutesPerDay;
    var remainderAfterDays = totalMinutes % minutesPerDay;
    var hours = remainderAfterDays ~/ Duration.minutesPerHour;
    var minutes = remainderAfterDays % Duration.minutesPerHour;
    var parts = <String>[
      if (days > 0)
        _formatDurationUnit(
          days,
          LocaleKeys.seriesEdit_seriesSettings_notifications_duration_day,
          LocaleKeys.seriesEdit_seriesSettings_notifications_duration_days,
        ),
      if (hours > 0)
        _formatDurationUnit(
          hours,
          LocaleKeys.seriesEdit_seriesSettings_notifications_duration_hour,
          LocaleKeys.seriesEdit_seriesSettings_notifications_duration_hours,
        ),
      _formatDurationUnit(
        minutes,
        LocaleKeys.seriesEdit_seriesSettings_notifications_duration_minute,
        LocaleKeys.seriesEdit_seriesSettings_notifications_duration_minutes,
      ),
    ];
    return LocaleKeys.seriesEdit_seriesSettings_notifications_snackbar_reminderIn.tr(args: [parts.join(' ')]);
  }

  String _formatDurationUnit(int value, String singularKey, String pluralKey) {
    return '${value.toString()} ${(value == 1 ? singularKey : pluralKey).tr()}';
  }
}

class _InfoTable extends StatelessWidget {
  final List<TableRow> rows;
  final Map<int, TableColumnWidth> Function(BoxConstraints constraints) columnWidthsBuilder;

  const _InfoTable({
    required this.rows,
    required this.columnWidthsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext _, BoxConstraints constraints) {
        return Table(
          columnWidths: columnWidthsBuilder(constraints),
          border: TableBorder.symmetric(
            inside: BorderSide(width: 1, color: themeData.canvasColor),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: rows,
        );
      },
    );
  }
}

class _EmptyInfo extends StatelessWidget {
  final String text;

  const _EmptyInfo(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: ThemeUtils.horizontalSpacingSmall,
      children: [
        Icon(
          Icons.info_outline,
          color: Theme.of(context).colorScheme.secondary,
          size: ThemeUtils.iconSizeScaled,
        ),
        Expanded(child: Text(text)),
      ],
    );
  }
}
