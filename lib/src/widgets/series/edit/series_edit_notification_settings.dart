import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../model/series/settings/notification_settings.dart';
import '../../../util/app_series_notifications.dart';
import '../../../util/media_query_utils.dart';
import '../../../util/theme_utils.dart';
import '../../controls/card/expandable.dart';
import '../../controls/layout/drop_down_menu_item_child.dart';

class SeriesEditNotificationSettings extends StatefulWidget {
  final SeriesDef seriesDef;
  final Function() updateStateCB;

  const SeriesEditNotificationSettings(this.seriesDef, this.updateStateCB, {super.key});

  @override
  State<SeriesEditNotificationSettings> createState() => _SeriesEditNotificationSettingsState();
}

class _SeriesEditNotificationSettingsState extends State<SeriesEditNotificationSettings> {
  static const double _repeatTypeDropdownBreakpoint = 300;
  static const double _repeatTypeCompactBreakpoint = 500;

  bool _queuedDefaultDailyTime = false;

  @override
  Widget build(BuildContext context) {
    var settings = widget.seriesDef.notificationSettingsEditable(widget.updateStateCB);
    var repeatType = settings.repeatType;
    var schedulingSupported = AppSeriesNotifications.isSchedulingSupportedOnCurrentPlatform;
    var nextReminderText = _buildNextReminderText();
    _queueDefaultDailyTimeIfNeeded(settings);

    return Expandable(
      initialExpanded: false,
      icon: Icon(Icons.notifications_active_outlined, size: ThemeUtils.iconSizeScaled),
      title: LocaleKeys.seriesEdit_seriesSettings_notifications_title.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!schedulingSupported) const _UnsupportedPlatformInfo(),
          SwitchListTile(
            title: Text(LocaleKeys.seriesEdit_seriesSettings_notifications_label_enabled.tr()),
            value: settings.enabled,
            onChanged: (value) {
              settings.enabled = value;
              if (value) {
                if (settings.repeatType == NotificationRepeatType.everyXDays && settings.everyXDaysAnchorUtcMs == null) {
                  var now = DateTime.now();
                  var anchor = DateTime(now.year, now.month, now.day).toUtc().millisecondsSinceEpoch;
                  settings.everyXDaysAnchorUtcMs = anchor;
                }
                _queueDefaultDailyTimeIfNeeded(settings, force: true);
              }
            },
            secondary: Icon(Icons.notifications_none_outlined, size: ThemeUtils.iconSizeScaled),
          ),
          if (settings.enabled) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.cardPadding, vertical: ThemeUtils.verticalSpacing),
              child: LayoutBuilder(
                builder: (context, constraints) => _buildRepeatTypeControl(
                  constraints,
                  settings,
                  repeatType,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.cardPadding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: ThemeUtils.verticalSpacing,
                    children: [
                      ...switch (repeatType) {
                        NotificationRepeatType.daily => _buildDailyRows(context, settings, constraints),
                        NotificationRepeatType.everyXDays => _buildEveryXDaysRows(context, settings, constraints),
                        NotificationRepeatType.weekly => _buildWeeklyRows(context, settings, constraints),
                        NotificationRepeatType.monthly => _buildMonthlyRows(context, settings, constraints),
                      },
                    ],
                  );
                },
              ),
            ),
            if (nextReminderText != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeUtils.cardPadding,
                  vertical: ThemeUtils.verticalSpacing,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: ThemeUtils.horizontalSpacingSmall,
                  children: [
                    Icon(Icons.notification_important_outlined, size: ThemeUtils.iconSizeScaled),
                    Text(
                      nextReminderText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.cardPadding),
              child: _buildReminderTextInput(settings),
            ),
          ],
        ],
      ),
    );
  }

  String? _buildNextReminderText() {
    if (!AppSeriesNotifications.isSchedulingSupportedOnCurrentPlatform) {
      return null;
    }

    var nextReminder = AppSeriesNotifications.nextScheduledNotificationAt(widget.seriesDef);
    if (nextReminder == null) {
      return null;
    }

    var durationText = _formatReminderDuration(nextReminder.difference(DateTime.now()));
    if (durationText == null) {
      return null;
    }
    return LocaleKeys.seriesEdit_seriesSettings_notifications_snackbar_reminderIn.tr(args: [durationText]);
  }

  String? _formatReminderDuration(Duration duration) {
    var totalMinutes = duration.inSeconds <= 0 ? 0 : (duration.inSeconds + Duration.secondsPerMinute - 1) ~/ Duration.secondsPerMinute;
    if (totalMinutes <= 0) {
      return null;
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
    return parts.join(' ');
  }

  String _formatDurationUnit(int value, String singularKey, String pluralKey) {
    return '${value.toString()} ${(value == 1 ? singularKey : pluralKey).tr()}';
  }

  Widget _buildRepeatTypeControl(
    BoxConstraints constraints,
    NotificationSettings settings,
    NotificationRepeatType repeatType,
  ) {
    if (constraints.maxWidth < _repeatTypeDropdownBreakpoint) {
      return DropdownButton<NotificationRepeatType>(
        borderRadius: ThemeUtils.cardBorderRadius,
        value: repeatType,
        onChanged: (value) {
          if (value == null) return;
          _selectRepeatType(settings, value);
        },
        items: NotificationRepeatType.values.map((value) {
          var label = _repeatTypeLabel(value).tr();
          return DropdownMenuItem(
            value: value,
            child: DropDownMenuItemChild(
              selected: repeatType == value,
              child: Text(label),
            ),
          );
        }).toList(),
      );
    }

    var compact = constraints.maxWidth < _repeatTypeCompactBreakpoint;
    return Center(
      child: SegmentedButton<NotificationRepeatType>(
        showSelectedIcon: false,
        multiSelectionEnabled: false,
        emptySelectionAllowed: false,
        segments: NotificationRepeatType.values
            .map(
              (value) => _repeatTypeSegment(
                value,
                selected: value == repeatType,
                compact: compact,
              ),
            )
            .toList(),
        selected: {repeatType},
        onSelectionChanged: (selected) {
          var selectedType = selected.firstOrNull;
          if (selectedType == null) return;
          _selectRepeatType(settings, selectedType);
        },
      ),
    );
  }

  ButtonSegment<NotificationRepeatType> _repeatTypeSegment(
    NotificationRepeatType value, {
    required bool selected,
    required bool compact,
  }) {
    var label = _repeatTypeLabel(value).tr();
    return ButtonSegment<NotificationRepeatType>(
      value: value,
      icon: Icon(_repeatTypeIcon(value), size: ThemeUtils.iconSizeScaled),
      label: compact
          ? null
          : Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
      tooltip: compact ? label : null,
    );
  }

  void _selectRepeatType(NotificationSettings settings, NotificationRepeatType selectedType) {
    settings.repeatType = selectedType;
    if (selectedType == NotificationRepeatType.everyXDays && settings.everyXDaysAnchorUtcMs == null) {
      var now = DateTime.now();
      var anchor = DateTime(now.year, now.month, now.day).toUtc().millisecondsSinceEpoch;
      settings.everyXDaysAnchorUtcMs = anchor;
    }
    if (selectedType == NotificationRepeatType.daily) {
      _queueDefaultDailyTimeIfNeeded(settings, force: true);
    }
    widget.updateStateCB();
  }

  List<Widget> _buildDailyRows(BuildContext context, NotificationSettings settings, BoxConstraints constraints) {
    var times = settings.dailyTimes;
    return [
      _tableRow(
        constraints,
        LocaleKeys.seriesEdit_seriesSettings_notifications_label_times.tr(),
        Wrap(
          spacing: ThemeUtils.horizontalSpacingSmall,
          runSpacing: ThemeUtils.verticalSpacingSmall,
          children: [
            ...times.map(
              (time) => InputChip(
                label: Text(_formatTimeLabel(context, time)),
                onPressed: () => _editDailyTime(context, settings, time),
                onDeleted: () => _removeDailyTime(settings, time),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _addDailyTime(context, settings),
              icon: const Icon(Icons.add_outlined),
              label: Text(LocaleKeys.seriesEdit_seriesSettings_notifications_action_addTime.tr()),
            ),
          ],
        ),
        iconData: Icons.schedule_outlined,
      ),
    ];
  }

  Widget _buildReminderTextInput(NotificationSettings settings) {
    var defaultReminderText = LocaleKeys.seriesEdit_seriesSettings_notifications_action_enterValue.tr();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: ThemeUtils.horizontalSpacingSmall,
      children: [
        Icon(Icons.message_outlined, size: ThemeUtils.iconSizeScaled),
        Expanded(
          child: TextFormField(
            initialValue: settings.reminderText ?? '',
            decoration: InputDecoration(
              labelText: LocaleKeys.seriesEdit_seriesSettings_notifications_label_reminderText.tr(),
              hintText: defaultReminderText,
            ),
            maxLength: NotificationSettings.maxReminderTextLength,
            textInputAction: TextInputAction.done,
            onChanged: (value) => settings.reminderText = value,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEveryXDaysRows(BuildContext context, NotificationSettings settings, BoxConstraints constraints) {
    return [
      _tableRow(
        constraints,
        LocaleKeys.commons_date_time.tr(),
        OutlinedButton.icon(
          onPressed: () => _pickSingleTime(context, settings),
          icon: const Icon(Icons.schedule_outlined),
          label: Text(_formatTimeLabel(context, settings.time)),
        ),
        iconData: Icons.schedule_outlined,
      ),
      _tableRow(
        constraints,
        LocaleKeys.seriesEdit_seriesSettings_notifications_label_intervalDays.tr(),
        _IntervalSpinner(
          value: settings.everyXDaysInterval,
          minValue: 1,
          maxValue: 365,
          onChanged: (value) => settings.everyXDaysInterval = value,
        ),
        iconData: Icons.repeat_outlined,
      ),
    ];
  }

  List<Widget> _buildWeeklyRows(BuildContext context, NotificationSettings settings, BoxConstraints constraints) {
    var selectedWeekdays = settings.weeklyWeekdays.toSet();
    var allWeekdays = <int>[
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];

    return [
      _tableRow(
        constraints,
        LocaleKeys.commons_date_time.tr(),
        OutlinedButton.icon(
          onPressed: () => _pickSingleTime(context, settings),
          icon: const Icon(Icons.schedule_outlined),
          label: Text(_formatTimeLabel(context, settings.time)),
        ),
        iconData: Icons.schedule_outlined,
      ),
      Row(
        spacing: ThemeUtils.horizontalSpacingSmall,
        children: [
          Icon(Icons.calendar_view_week_outlined, size: ThemeUtils.iconSizeScaled),
          Text(LocaleKeys.seriesEdit_seriesSettings_notifications_label_weekdays.tr()),
        ],
      ),
      Wrap(
        spacing: ThemeUtils.horizontalSpacingSmall,
        runSpacing: ThemeUtils.verticalSpacingSmall,
        children: allWeekdays.map((weekday) {
          var selected = selectedWeekdays.contains(weekday);
          return FilterChip(
            selected: selected,
            label: Text(
              _weekdayLabel(weekday).tr(),
              style: TextStyle(color: selected ? ThemeUtils.onPrimary : null),
            ),
            onSelected: (value) {
              var next = {...selectedWeekdays};
              if (value) {
                next.add(weekday);
              } else {
                next.remove(weekday);
              }
              if (next.isEmpty) {
                return;
              }
              settings.weeklyWeekdays = next.toList();
            },
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildMonthlyRows(BuildContext context, NotificationSettings settings, BoxConstraints constraints) {
    var selectedMonthlyRule = settings.monthlyRule;

    return [
      _tableRow(
        constraints,
        LocaleKeys.commons_date_time.tr(),
        OutlinedButton.icon(
          onPressed: () => _pickSingleTime(context, settings),
          icon: const Icon(Icons.schedule_outlined),
          label: Text(_formatTimeLabel(context, settings.time)),
        ),
        iconData: Icons.schedule_outlined,
      ),
      _tableRow(
        constraints,
        LocaleKeys.seriesEdit_seriesSettings_notifications_label_monthlyRule.tr(),
        DropdownButton<NotificationMonthlyRule>(
          borderRadius: ThemeUtils.cardBorderRadius,
          value: selectedMonthlyRule,
          onChanged: (value) {
            if (value == null) return;
            settings.monthlyRule = value;
          },
          items: [
            DropdownMenuItem(
              value: NotificationMonthlyRule.dayOfMonth,
              child: DropDownMenuItemChild(
                selected: selectedMonthlyRule == NotificationMonthlyRule.dayOfMonth,
                child: Text(LocaleKeys.seriesEdit_seriesSettings_notifications_monthlyRule_dayOfMonth.tr()),
              ),
            ),
            DropdownMenuItem(
              value: NotificationMonthlyRule.lastDay,
              child: DropDownMenuItemChild(
                selected: selectedMonthlyRule == NotificationMonthlyRule.lastDay,
                child: Text(LocaleKeys.seriesEdit_seriesSettings_notifications_monthlyRule_lastDay.tr()),
              ),
            ),
            DropdownMenuItem(
              value: NotificationMonthlyRule.weekdayOfMonth,
              child: DropDownMenuItemChild(
                selected: selectedMonthlyRule == NotificationMonthlyRule.weekdayOfMonth,
                child: Text(LocaleKeys.seriesEdit_seriesSettings_notifications_monthlyRule_weekdayOfMonth.tr()),
              ),
            ),
          ],
        ),
        iconData: Icons.calendar_month_outlined,
      ),
      if (selectedMonthlyRule == NotificationMonthlyRule.dayOfMonth)
        _tableRow(
          constraints,
          LocaleKeys.seriesEdit_seriesSettings_notifications_label_day.tr(),
          DropdownButton<int>(
            borderRadius: ThemeUtils.cardBorderRadius,
            value: settings.monthlyDay,
            onChanged: (value) {
              if (value == null) return;
              _selectMonthlyDay(settings, value);
            },
            items: List.generate(31, (index) {
              var day = index + 1;
              return DropdownMenuItem(
                value: day,
                child: DropDownMenuItemChild(
                  selected: settings.monthlyDay == day,
                  child: Text('$day'),
                ),
              );
            }),
          ),
          iconData: Icons.calendar_today_outlined,
        ),
      if (selectedMonthlyRule == NotificationMonthlyRule.weekdayOfMonth)
        _tableRow(
          constraints,
          LocaleKeys.seriesEdit_seriesSettings_notifications_label_day.tr(),
          Wrap(
            spacing: ThemeUtils.horizontalSpacingSmall,
            runSpacing: ThemeUtils.verticalSpacingSmall,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<int>(
                borderRadius: ThemeUtils.cardBorderRadius,
                value: settings.monthlyWeekdayOrdinal,
                onChanged: (value) {
                  if (value == null) return;
                  settings.monthlyWeekdayOrdinal = value;
                },
                items: [1, 2, 3, -1].map((ordinal) {
                  return DropdownMenuItem(
                    value: ordinal,
                    child: DropDownMenuItemChild(
                      selected: settings.monthlyWeekdayOrdinal == ordinal,
                      child: Text(_monthlyWeekdayOrdinalLabel(ordinal).tr()),
                    ),
                  );
                }).toList(),
              ),
              DropdownButton<int>(
                borderRadius: ThemeUtils.cardBorderRadius,
                value: settings.monthlyWeekday,
                onChanged: (value) {
                  if (value == null) return;
                  settings.monthlyWeekday = value;
                },
                items:
                    [
                      DateTime.monday,
                      DateTime.tuesday,
                      DateTime.wednesday,
                      DateTime.thursday,
                      DateTime.friday,
                      DateTime.saturday,
                      DateTime.sunday,
                    ].map((weekday) {
                      return DropdownMenuItem(
                        value: weekday,
                        child: DropDownMenuItemChild(
                          selected: settings.monthlyWeekday == weekday,
                          child: Text(_weekdayLabel(weekday).tr()),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
          iconData: Icons.calendar_today_outlined,
        ),
    ];
  }

  void _selectMonthlyDay(NotificationSettings settings, int day) {
    settings.monthlyDay = day;
  }

  Widget _tableRow(BoxConstraints constraints, String label, Widget setting, {IconData? iconData}) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: ThemeUtils.horizontalSpacingSmall,
      runSpacing: ThemeUtils.verticalSpacingSmall,
      children: [
        SizedBox(
          width: max(130 * MediaQueryUtils.textScaleWidthFactor, constraints.maxWidth / 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: ThemeUtils.horizontalSpacingSmall,
            children: [
              if (iconData != null) Icon(iconData, size: ThemeUtils.iconSizeScaled),
              Flexible(child: Text(label)),
            ],
          ),
        ),
        // SizedBox(
        //   width: min(320 * MediaQueryUtils.textScaleWidthFactor, constraints.maxWidth),
        //   child: setting,
        // ),
        setting,
      ],
    );
  }

  String _repeatTypeLabel(NotificationRepeatType value) {
    return switch (value) {
      NotificationRepeatType.daily => LocaleKeys.seriesEdit_seriesSettings_notifications_repeat_daily,
      NotificationRepeatType.everyXDays => LocaleKeys.seriesEdit_seriesSettings_notifications_repeat_everyXDays,
      NotificationRepeatType.weekly => LocaleKeys.seriesEdit_seriesSettings_notifications_repeat_weekly,
      NotificationRepeatType.monthly => LocaleKeys.seriesEdit_seriesSettings_notifications_repeat_monthly,
    };
  }

  IconData _repeatTypeIcon(NotificationRepeatType value) {
    return switch (value) {
      NotificationRepeatType.daily => Icons.today_outlined,
      NotificationRepeatType.everyXDays => Icons.event_repeat_outlined,
      NotificationRepeatType.weekly => Icons.calendar_view_week_outlined,
      NotificationRepeatType.monthly => Icons.calendar_month_outlined,
    };
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => LocaleKeys.commons_date_shortWeekday_monday,
      DateTime.tuesday => LocaleKeys.commons_date_shortWeekday_tuesday,
      DateTime.wednesday => LocaleKeys.commons_date_shortWeekday_wednesday,
      DateTime.thursday => LocaleKeys.commons_date_shortWeekday_thursday,
      DateTime.friday => LocaleKeys.commons_date_shortWeekday_friday,
      DateTime.saturday => LocaleKeys.commons_date_shortWeekday_saturday,
      DateTime.sunday => LocaleKeys.commons_date_shortWeekday_sunday,
      _ => LocaleKeys.commons_date_shortWeekday_monday,
    };
  }

  String _monthlyWeekdayOrdinalLabel(int ordinal) {
    return switch (ordinal) {
      1 => LocaleKeys.seriesEdit_seriesSettings_notifications_monthlyWeekdayOrdinal_first,
      2 => LocaleKeys.seriesEdit_seriesSettings_notifications_monthlyWeekdayOrdinal_second,
      3 => LocaleKeys.seriesEdit_seriesSettings_notifications_monthlyWeekdayOrdinal_third,
      -1 => LocaleKeys.seriesEdit_seriesSettings_notifications_monthlyWeekdayOrdinal_last,
      _ => LocaleKeys.seriesEdit_seriesSettings_notifications_monthlyWeekdayOrdinal_first,
    };
  }

  Future<void> _addDailyTime(BuildContext context, NotificationSettings settings) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    var hhmm = _formatAsHHmm(picked);
    var values = [...settings.dailyTimes];
    if (!values.contains(hhmm)) {
      values.add(hhmm);
      values.sort();
      settings.dailyTimes = values;
    }
  }

  Future<void> _editDailyTime(BuildContext context, NotificationSettings settings, String oldValue) async {
    var hm = _parseHHmm(oldValue);
    var picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hm.$1, minute: hm.$2),
    );
    if (picked == null) return;
    var hhmm = _formatAsHHmm(picked);
    var values = [...settings.dailyTimes];
    values.remove(oldValue);
    values.add(hhmm);
    values = values.toSet().toList()..sort();
    settings.dailyTimes = values;
  }

  void _removeDailyTime(NotificationSettings settings, String value) {
    var values = [...settings.dailyTimes]..remove(value);
    settings.dailyTimes = values;
    _queueDefaultDailyTimeIfNeeded(settings, force: true);
  }

  Future<void> _pickSingleTime(BuildContext context, NotificationSettings settings) async {
    var hm = _parseHHmm(settings.time);
    var picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hm.$1, minute: hm.$2),
    );
    if (picked == null) return;
    settings.time = _formatAsHHmm(picked);
  }

  String _formatTimeLabel(BuildContext context, String hhmm) {
    var hm = _parseHHmm(hhmm);
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: hm.$1, minute: hm.$2),
      alwaysUse24HourFormat: true,
    );
  }

  (int, int) _parseHHmm(String value) {
    var parts = value.split(':');
    var hour = int.tryParse(parts.firstOrNull ?? '') ?? 0;
    var minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return (hour.clamp(0, 23), minute.clamp(0, 59));
  }

  String _formatAsHHmm(TimeOfDay value) {
    var h = value.hour.toString().padLeft(2, '0');
    var m = value.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _queueDefaultDailyTimeIfNeeded(NotificationSettings settings, {bool force = false}) {
    var needsDefault = settings.enabled && settings.repeatType == NotificationRepeatType.daily && settings.dailyTimes.isEmpty;
    if (!needsDefault) {
      return;
    }
    if (_queuedDefaultDailyTime && !force) {
      return;
    }
    _queuedDefaultDailyTime = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queuedDefaultDailyTime = false;
      var refreshSettings = widget.seriesDef.notificationSettingsEditable(widget.updateStateCB);
      var stillNeeded = refreshSettings.enabled && refreshSettings.repeatType == NotificationRepeatType.daily && refreshSettings.dailyTimes.isEmpty;
      if (!stillNeeded) {
        return;
      }
      refreshSettings.dailyTimes = [_buildDefaultDailyTime()];
    });
  }

  String _buildDefaultDailyTime() {
    var now = DateTime.now().add(const Duration(minutes: 10));
    var rounded = DateTime(now.year, now.month, now.day, now.hour);
    if (now.minute > 0 || now.second > 0 || now.millisecond > 0 || now.microsecond > 0) {
      rounded = rounded.add(const Duration(hours: 1));
    }
    return '${rounded.hour.toString().padLeft(2, '0')}:00';
  }
}

class _UnsupportedPlatformInfo extends StatelessWidget {
  const _UnsupportedPlatformInfo();

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeUtils.cardPadding,
        vertical: ThemeUtils.verticalSpacingSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: ThemeUtils.horizontalSpacingSmall,
        children: [
          Icon(
            Icons.info_outline,
            size: ThemeUtils.iconSizeScaled,
            color: themeData.colorScheme.secondary,
          ),
          Expanded(
            child: Text(
              LocaleKeys.seriesEdit_seriesSettings_notifications_label_unsupportedPlatform.tr(),
              style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntervalSpinner extends StatelessWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const _IntervalSpinner({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: ThemeUtils.cardBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            onPressed: value <= minValue ? null : () => onChanged(value - 1),
            icon: const Icon(Icons.remove_outlined),
          ),
          SizedBox(
            width: 48 * MediaQueryUtils.textScaleWidthFactor,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            iconSize: ThemeUtils.iconSizeScaled,
            onPressed: value >= maxValue ? null : () => onChanged(value + 1),
            icon: const Icon(Icons.add_outlined),
          ),
        ],
      ),
    );
  }
}
