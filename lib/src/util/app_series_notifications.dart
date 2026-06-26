import 'dart:convert';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../generated/locale_keys.g.dart';
import '../model/series/series_def.dart';
import '../model/series/settings/notification_settings.dart';
import '../store/store_series_notifications.dart';
import '../store/stores.dart';
import 'app_icon_quick_actions.dart';
import 'logging/flutter_simple_logging.dart';
import 'pending_app_actions.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundSeriesNotificationResponse(NotificationResponse response) {
  AppSeriesNotifications.handleNotificationResponse(response);
}

class AppSeriesNotifications {
  static const _debugShowNotificationOnInit = false;
  static const _actionSeriesAddPrefix = 'series_add_';
  static const _channelId = 'series_notifications';
  static const _channelName = 'Series notifications';
  static const _channelDescription = 'Measurement reminders for configured series';
  static const _groupKey = 'series_notifications_group';
  static const _scheduledIntervalCount = 6;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _debugNotificationShownThisRun = false;

  static Future<void> init() async {
    if (!_isSupportedPlatform()) {
      SimpleLogging.d('Series notifications init skipped: unsupported platform.');
      return;
    }

    if (_initialized) {
      SimpleLogging.d('Series notifications init skipped: already initialized.');
      return;
    }

    try {
      SimpleLogging.d('Initializing series notifications ...');
      await _configureTimezone();

      const androidInitSettings = AndroidInitializationSettings('app_logo_notification');
      const initializationSettings = InitializationSettings(
        android: androidInitSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundSeriesNotificationResponse,
      );

      final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
      SimpleLogging.d('Series notification launch details loaded. launchedByNotification=${launchDetails?.didNotificationLaunchApp == true}');
      if (launchDetails?.didNotificationLaunchApp == true) {
        var notificationResponse = launchDetails?.notificationResponse;
        if (notificationResponse != null) {
          handleNotificationResponse(notificationResponse);
        }
      }

      _initialized = true;
      SimpleLogging.d('Series notifications initialized.');
      await _showDebugNotificationIfEnabled();
    } catch (err, st) {
      SimpleLogging.w('Could not initialize series notifications', error: err, stackTrace: st);
    }
  }

  static Future<void> queueActiveSeriesNotificationActions() async {
    if (!_isSupportedPlatform()) {
      SimpleLogging.d('Queue active series notifications skipped: unsupported platform.');
      return;
    }
    await init();
    if (!_initialized) {
      SimpleLogging.d('Queue active series notifications skipped: notifications are not initialized.');
      return;
    }

    try {
      var activeNotifications = await _notificationsPlugin.getActiveNotifications();
      if (activeNotifications.isEmpty) {
        SimpleLogging.d('No active notifications found.');
        return;
      }

      var entries = await Stores.storeSeriesNotifications.getAll();
      var seriesUuidByNotificationId = <int, String>{};
      for (var entry in entries) {
        for (var notificationId in entry.notificationIds) {
          seriesUuidByNotificationId[notificationId] = entry.seriesDefUuid;
        }
      }
      SimpleLogging.d(
        'Loaded active series notification sync state. activeIds=${activeNotifications.map((notification) => notification.id).whereType<int>().toList()}, storedIds=${seriesUuidByNotificationId.keys.toList()}',
      );

      var queuedCount = 0;
      for (var activeNotification in activeNotifications) {
        var notificationId = activeNotification.id;
        if (notificationId == null) {
          continue;
        }

        var seriesUuid = seriesUuidByNotificationId[notificationId];
        if (seriesUuid == null) {
          continue;
        }

        PendingAppActions.enqueueSeriesValue(
          seriesUuid: seriesUuid,
          source: PendingSeriesActionSource.notification,
          notificationId: notificationId,
        );
        queuedCount++;
      }

      SimpleLogging.d('Queued active series notifications. active=${activeNotifications.length}, matched=$queuedCount');
    } catch (err, st) {
      SimpleLogging.w('Could not queue active series notifications', error: err, stackTrace: st);
    }
  }

  static void handleNotificationResponse(NotificationResponse response) {
    handleNotificationResponsePayload(response.payload, notificationId: response.id);
  }

  static void handleNotificationResponsePayload(String? payload, {int? notificationId}) {
    if (payload == null || payload.isEmpty) {
      SimpleLogging.d('Ignored series notification response: empty payload.');
      return;
    }
    if (!payload.startsWith(_actionSeriesAddPrefix)) {
      SimpleLogging.d('Ignored series notification response: unsupported payload "$payload".');
      return;
    }
    var seriesUuid = payload.substring(_actionSeriesAddPrefix.length);
    if (seriesUuid.trim().isEmpty) {
      SimpleLogging.d('Ignored series notification response: missing series uuid.');
      return;
    }
    PendingAppActions.enqueueSeriesValue(
      seriesUuid: seriesUuid,
      source: PendingSeriesActionSource.notification,
      notificationId: notificationId,
    );
    SimpleLogging.d('Handled series notification response. seriesUuid=$seriesUuid, notificationId=$notificationId');
  }

  static Future<bool> ensurePermissionRequested() async {
    if (!_isSupportedPlatform()) {
      SimpleLogging.d('Series notification permission request skipped: unsupported platform.');
      return false;
    }
    SimpleLogging.d('Requesting series notification permission ...');
    await init();

    try {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final allowed = await androidPlugin.requestNotificationsPermission();
        SimpleLogging.d('Series notification permission request completed. allowed=$allowed');
        if (allowed == true) {
          await _requestExactAlarmsPermissionIfNeeded(androidPlugin);
          await _showDebugNotificationIfEnabled();
        }
        return allowed ?? false;
      }
    } catch (err, st) {
      SimpleLogging.w('Could not request notification permission', error: err, stackTrace: st);
      return false;
    }

    SimpleLogging.d('Series notification permission request skipped: no Android notification plugin implementation.');
    return true;
  }

  static Future<void> refreshDueSeriesNotifications(List<SeriesDef> series) async {
    if (!_isSupportedPlatform()) {
      SimpleLogging.d('Refresh due series notifications skipped: unsupported platform.');
      return;
    }
    SimpleLogging.d('Refreshing due series notifications for ${series.length} series ...');
    await init();
    if (!_initialized) {
      SimpleLogging.d('Refresh due series notifications skipped: notifications are not initialized.');
      return;
    }

    try {
      var store = Stores.storeSeriesNotifications;
      var existingEntries = await store.getAll();
      var existingBySeries = {for (var entry in existingEntries) entry.seriesDefUuid: entry};
      var validSeriesIds = series.map((s) => s.uuid).toSet();
      var enabledSeries = series.where((s) => s.notificationSettingsReadonly().enabled).toList();
      var enabledSeriesIds = enabledSeries.map((s) => s.uuid).toSet();
      var scheduleMode = await _androidScheduleModeForReminders();
      var now = DateTime.now();
      var nowUtc = now.toUtc();
      SimpleLogging.d(
        'Loaded series notification state. stored=${existingEntries.length}, enabled=${enabledSeries.length}, scheduleMode=$scheduleMode',
      );

      for (var entry in existingEntries) {
        if (!validSeriesIds.contains(entry.seriesDefUuid) || !enabledSeriesIds.contains(entry.seriesDefUuid)) {
          SimpleLogging.d(
            'Deleting stale series notifications. seriesUuid=${entry.seriesDefUuid}, notificationIds=${entry.notificationIds}',
          );
          await _cancelNotifications(entry.notificationIds);
          await store.delete(entry.seriesDefUuid);
        }
      }

      var globallyUsedIds = existingEntries.where((entry) => enabledSeriesIds.contains(entry.seriesDefUuid)).expand((entry) => entry.notificationIds).toSet();
      for (var seriesDef in enabledSeries) {
        var existing = existingBySeries[seriesDef.uuid];
        if (existing != null) {
          globallyUsedIds.removeAll(existing.notificationIds);
        }
        await _refreshSeriesNotification(
          seriesDef,
          existing: existing,
          scheduleMode: scheduleMode,
          globallyUsedIds: globallyUsedIds,
          now: now,
          nowUtc: nowUtc,
          force: false,
        );
        var refreshed = await store.get(seriesDef.uuid);
        if (refreshed != null) {
          globallyUsedIds.addAll(refreshed.notificationIds);
        }
      }
      SimpleLogging.d('Finished refreshing due series notifications.');
    } catch (err, st) {
      SimpleLogging.w('Could not refresh due series notifications', error: err, stackTrace: st);
    }
  }

  static Future<void> refreshSeriesNotification(SeriesDef seriesDef, {bool force = false}) async {
    if (!_isSupportedPlatform()) {
      SimpleLogging.d('Refresh series notification skipped: unsupported platform. seriesUuid=${seriesDef.uuid}');
      return;
    }
    SimpleLogging.d('Refreshing series notifications. seriesUuid=${seriesDef.uuid}, force=$force');
    await init();
    if (!_initialized) {
      SimpleLogging.d('Refresh series notification skipped: notifications are not initialized. seriesUuid=${seriesDef.uuid}');
      return;
    }

    try {
      var store = Stores.storeSeriesNotifications;
      var existingEntries = await store.getAll();
      var existing = existingEntries.where((entry) => entry.seriesDefUuid == seriesDef.uuid).firstOrNull;
      var scheduleMode = await _androidScheduleModeForReminders();
      var globallyUsedIds = existingEntries.where((entry) => entry.seriesDefUuid != seriesDef.uuid).expand((entry) => entry.notificationIds).toSet();
      var now = DateTime.now();
      await _refreshSeriesNotification(
        seriesDef,
        existing: existing,
        scheduleMode: scheduleMode,
        globallyUsedIds: globallyUsedIds,
        now: now,
        nowUtc: now.toUtc(),
        force: force,
      );
      SimpleLogging.d('Finished refreshing series notifications. seriesUuid=${seriesDef.uuid}');
    } catch (err, st) {
      SimpleLogging.w('Could not refresh series notifications for ${seriesDef.uuid}', error: err, stackTrace: st);
    }
  }

  static Future<void> deleteSeriesNotifications(String seriesUuid) async {
    SimpleLogging.d('Deleting series notifications. seriesUuid=$seriesUuid');
    await init();
    if (!_initialized) {
      SimpleLogging.d('Delete series notifications skipped: notifications are not initialized. seriesUuid=$seriesUuid');
      return;
    }

    try {
      var store = Stores.storeSeriesNotifications;
      var existing = await store.get(seriesUuid);
      SimpleLogging.d('Loaded series notifications for delete. seriesUuid=$seriesUuid, notificationIds=${existing?.notificationIds ?? const []}');
      await _cancelNotifications(existing?.notificationIds ?? const []);
      await store.delete(seriesUuid);
      SimpleLogging.d('Deleted series notifications. seriesUuid=$seriesUuid');
    } catch (err, st) {
      SimpleLogging.w('Could not delete series notifications for $seriesUuid', error: err, stackTrace: st);
    }
  }

  static bool notificationScheduleChanged(SeriesDef? before, SeriesDef after) {
    if (before == null) {
      return after.notificationSettingsReadonly().enabled;
    }
    return _buildSeriesSignature(before) != _buildSeriesSignature(after);
  }

  static DateTime? nextScheduledNotificationAt(SeriesDef seriesDef, {DateTime? now}) {
    return _buildScheduleSpec(seriesDef, now ?? DateTime.now()).firstOrNull;
  }

  /// Returns all future notification times that are planned for [seriesDef].
  static List<DateTime> scheduledNotificationTimes(SeriesDef seriesDef, {DateTime? now}) {
    return List.unmodifiable(_buildScheduleSpec(seriesDef, now ?? DateTime.now()));
  }

  static bool get isSchedulingSupportedOnCurrentPlatform => _isSupportedPlatform();

  static Future<void> _refreshSeriesNotification(
    SeriesDef seriesDef, {
    required SeriesNotificationsStoreEntry? existing,
    required AndroidScheduleMode scheduleMode,
    required Set<int> globallyUsedIds,
    required DateTime now,
    required DateTime nowUtc,
    required bool force,
  }) async {
    var store = Stores.storeSeriesNotifications;
    if (!seriesDef.notificationSettingsReadonly().enabled) {
      SimpleLogging.d('Series notifications disabled. Deleting stored notifications. seriesUuid=${seriesDef.uuid}');
      await _cancelNotifications(existing?.notificationIds ?? const []);
      await store.delete(seriesDef.uuid);
      return;
    }

    var scheduleSpec = _buildScheduleSpec(seriesDef, now);
    var signature = _buildSeriesSignature(seriesDef);
    var triggerUtcMs = _triggerUtcMs(scheduleSpec);
    SimpleLogging.d(
      'Built series notification schedule. seriesUuid=${seriesDef.uuid}, triggerCount=${scheduleSpec.length}, force=$force',
    );
    if (!force && !_needsRefresh(existing, signature, triggerUtcMs, nowUtc)) {
      SimpleLogging.d('Series notification refresh skipped: stored schedule is up to date. seriesUuid=${seriesDef.uuid}');
      return;
    }

    SimpleLogging.d(
      'Replacing series notifications. seriesUuid=${seriesDef.uuid}, existingNotificationIds=${existing?.notificationIds ?? const []}',
    );
    await _cancelNotifications(existing?.notificationIds ?? const []);

    var ids = <int>[];
    for (var trigger in scheduleSpec) {
      var id = _buildNotificationId(seriesDef.uuid, trigger, globallyUsedIds);
      globallyUsedIds.add(id);
      await _notificationsPlugin.zonedSchedule(
        id,
        seriesDef.name,
        LocaleKeys.seriesEdit_seriesSettings_notifications_action_enterValue.tr(),
        tz.TZDateTime.from(trigger, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            icon: 'app_logo_notification',
            groupKey: _groupKey,
            importance: Importance.high,
            priority: Priority.high,
            sound: const RawResourceAndroidNotificationSound('notification'),
            largeIcon: DrawableResourceAndroidBitmap(AppIconQuickActions.notificationIconNameForSeriesColor(seriesDef.color)),
          ),
        ),
        payload: '$_actionSeriesAddPrefix${seriesDef.uuid}',
        androidScheduleMode: scheduleMode,
      );
      ids.add(id);
      SimpleLogging.d(
        'Scheduled series notification. seriesUuid=${seriesDef.uuid}, notificationId=$id, triggerLocal=$trigger, scheduleMode=$scheduleMode',
      );
    }

    if (ids.isNotEmpty) {
      await store.save(
        SeriesNotificationsStoreEntry(
          seriesDefUuid: seriesDef.uuid,
          notificationIds: ids,
          scheduledAtUtcMs: nowUtc.millisecondsSinceEpoch,
          scheduleSignature: signature,
          triggerUtcMs: triggerUtcMs,
        ),
      );
      SimpleLogging.d('Saved series notification state. seriesUuid=${seriesDef.uuid}, notificationIds=$ids');
    } else {
      await store.delete(seriesDef.uuid);
      SimpleLogging.d('Deleted series notification state because no future triggers exist. seriesUuid=${seriesDef.uuid}');
    }
  }

  static bool _needsRefresh(SeriesNotificationsStoreEntry? existing, String signature, List<int> triggerUtcMs, DateTime nowUtc) {
    if (existing == null) {
      var needsRefresh = triggerUtcMs.isNotEmpty;
      SimpleLogging.d('Series notification refresh check: no stored entry. needsRefresh=$needsRefresh, triggerCount=${triggerUtcMs.length}');
      return needsRefresh;
    }
    if (existing.scheduleSignature != signature) {
      SimpleLogging.d('Series notification refresh check: schedule signature changed. seriesUuid=${existing.seriesDefUuid}');
      return true;
    }
    if (existing.triggerUtcMs.isEmpty && existing.notificationIds.isNotEmpty) {
      SimpleLogging.d('Series notification refresh check: stored notification ids have no trigger metadata. seriesUuid=${existing.seriesDefUuid}');
      return true;
    }

    var expectedTriggers = triggerUtcMs.toSet();
    var storedFutureTriggers = existing.triggerUtcMs.where((triggerUtcMs) => triggerUtcMs > nowUtc.millisecondsSinceEpoch).toSet();
    var needsRefresh = !setEquals(storedFutureTriggers, expectedTriggers);
    SimpleLogging.d(
      'Series notification refresh check: trigger comparison completed. seriesUuid=${existing.seriesDefUuid}, needsRefresh=$needsRefresh, storedFutureCount=${storedFutureTriggers.length}, expectedCount=${expectedTriggers.length}',
    );
    return needsRefresh;
  }

  static List<int> _triggerUtcMs(List<DateTime> triggers) {
    return triggers.map((trigger) => trigger.toUtc().millisecondsSinceEpoch).toList()..sort();
  }

  static Future<void> _cancelNotifications(List<int> notificationIds) async {
    if (notificationIds.isEmpty) {
      SimpleLogging.d('No series notifications to cancel.');
      return;
    }
    SimpleLogging.d('Cancelling series notifications. notificationIds=$notificationIds');
    for (var id in notificationIds) {
      await _notificationsPlugin.cancel(id);
    }
    SimpleLogging.d('Cancelled series notifications. notificationIds=$notificationIds');
  }

  static Future<void> _requestExactAlarmsPermissionIfNeeded(AndroidFlutterLocalNotificationsPlugin androidPlugin) async {
    try {
      var canScheduleExact = await androidPlugin.canScheduleExactNotifications();
      SimpleLogging.d('Checked exact alarm permission before request. canScheduleExact=$canScheduleExact');
      if (canScheduleExact == true) {
        return;
      }

      var granted = await androidPlugin.requestExactAlarmsPermission();
      if (granted == true) {
        SimpleLogging.i('Exact alarm permission granted. Series notifications will use exact scheduling.');
      } else {
        SimpleLogging.i('Exact alarm permission not granted. Series notifications will use inexact scheduling.');
      }
    } catch (err, st) {
      SimpleLogging.w('Could not request exact alarm permission', error: err, stackTrace: st);
    }
  }

  static Future<AndroidScheduleMode> _androidScheduleModeForReminders() async {
    try {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      var canScheduleExact = await androidPlugin?.canScheduleExactNotifications();
      if (canScheduleExact == true) {
        SimpleLogging.d('Using exact series notification scheduling.');
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
      SimpleLogging.d('Using inexact series notification scheduling. canScheduleExact=$canScheduleExact');
    } catch (err, st) {
      SimpleLogging.w('Could not check exact alarm permission', error: err, stackTrace: st);
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  static Future<void> _showDebugNotificationIfEnabled() async {
    if (!kDebugMode || !_debugShowNotificationOnInit || _debugNotificationShownThisRun || !_initialized) {
      SimpleLogging.d(
        'Debug series notification skipped. kDebugMode=$kDebugMode, enabled=$_debugShowNotificationOnInit, alreadyShown=$_debugNotificationShownThisRun, initialized=$_initialized',
      );
      return;
    }

    try {
      SimpleLogging.d('Showing immediate debug series notification ...');
      await _notificationsPlugin.show(
        999001,
        'xTracker notification test',
        'Immediate debug notification',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            icon: 'app_logo_notification',
            importance: Importance.high,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('notification'),
          ),
        ),
      );
      _debugNotificationShownThisRun = true;
      SimpleLogging.d('Immediate debug series notification shown.');
    } catch (err, st) {
      SimpleLogging.w('Could not show debug notification', error: err, stackTrace: st);
    }
  }

  static List<DateTime> _buildScheduleSpec(SeriesDef seriesDef, DateTime now) {
    var settings = seriesDef.notificationSettingsReadonly();
    if (!settings.enabled) return const [];

    List<DateTime> result = switch (settings.repeatType) {
      NotificationRepeatType.daily => _buildDailySchedule(settings, now),
      NotificationRepeatType.everyXDays => _buildEveryXDaysSchedule(settings, now),
      NotificationRepeatType.weekly => _buildWeeklySchedule(settings, now),
      NotificationRepeatType.monthly => _buildMonthlySchedule(settings, now),
    };
    result.sort();
    return result.where((dt) => dt.isAfter(now)).toList();
  }

  static List<DateTime> _buildDailySchedule(NotificationSettings settings, DateTime now) {
    var times = settings.dailyTimes;
    if (times.isEmpty) {
      times = ['08:00'];
    }

    var result = <DateTime>[];
    var date = DateTime(now.year, now.month, now.day);
    var intervalCount = 0;
    while (intervalCount < _scheduledIntervalCount) {
      var addedForDate = false;
      for (var time in times) {
        var hm = _parseTime(time);
        var candidate = DateTime(date.year, date.month, date.day, hm.$1, hm.$2);
        if (candidate.isAfter(now)) {
          result.add(candidate);
          addedForDate = true;
        }
      }
      if (addedForDate) {
        intervalCount++;
      }
      date = date.add(const Duration(days: 1));
    }
    return result;
  }

  static List<DateTime> _buildEveryXDaysSchedule(NotificationSettings settings, DateTime now) {
    var interval = settings.everyXDaysInterval;
    var anchorUtc = settings.everyXDaysAnchorUtcMs;
    var anchorLocal = anchorUtc != null ? DateTime.fromMillisecondsSinceEpoch(anchorUtc, isUtc: true).toLocal() : DateTime(now.year, now.month, now.day);
    anchorLocal = DateTime(anchorLocal.year, anchorLocal.month, anchorLocal.day);
    var hm = _parseTime(settings.time);

    var result = <DateTime>[];
    var candidate = DateTime(anchorLocal.year, anchorLocal.month, anchorLocal.day, hm.$1, hm.$2);
    while (!candidate.isAfter(now)) {
      candidate = candidate.add(Duration(days: interval));
    }
    while (result.length < _scheduledIntervalCount) {
      result.add(candidate);
      candidate = candidate.add(Duration(days: interval));
    }
    return result;
  }

  static List<DateTime> _buildWeeklySchedule(NotificationSettings settings, DateTime now) {
    var weekdays = settings.weeklyWeekdays.toSet();
    if (weekdays.isEmpty) {
      weekdays = {DateTime.monday};
    }
    var hm = _parseTime(settings.time);

    var result = <DateTime>[];
    var date = DateTime(now.year, now.month, now.day);
    var intervalCount = 0;
    while (intervalCount < _scheduledIntervalCount) {
      var addedForWeek = false;
      for (var i = 0; i < DateTime.daysPerWeek; i++) {
        var candidateDate = date.add(Duration(days: i));
        if (!weekdays.contains(candidateDate.weekday)) {
          continue;
        }
        var candidate = DateTime(candidateDate.year, candidateDate.month, candidateDate.day, hm.$1, hm.$2);
        if (candidate.isAfter(now)) {
          result.add(candidate);
          addedForWeek = true;
        }
      }
      if (addedForWeek) {
        intervalCount++;
      }
      date = date.add(const Duration(days: DateTime.daysPerWeek));
    }
    return result;
  }

  static List<DateTime> _buildMonthlySchedule(NotificationSettings settings, DateTime now) {
    var hm = _parseTime(settings.time);
    var result = <DateTime>[];

    var monthCursor = DateTime(now.year, now.month);
    while (result.length < _scheduledIntervalCount) {
      var year = monthCursor.year;
      var month = monthCursor.month;
      var date = _resolveMonthlyDate(settings, year, month);
      var candidate = DateTime(date.year, date.month, date.day, hm.$1, hm.$2);
      if (candidate.isAfter(now)) {
        result.add(candidate);
      }
      monthCursor = DateTime(year, month + 1);
    }
    return result;
  }

  static DateTime _resolveMonthlyDate(NotificationSettings settings, int year, int month) {
    var lastDay = DateTime(year, month + 1, 0).day;
    return switch (settings.monthlyRule) {
      NotificationMonthlyRule.lastDay => DateTime(year, month, lastDay),
      NotificationMonthlyRule.dayOfMonth => DateTime(year, month, math.min(lastDay, settings.monthlyDay)),
      NotificationMonthlyRule.weekdayOfMonth => _resolveWeekdayOfMonth(
        year,
        month,
        settings.monthlyWeekdayOrdinal,
        settings.monthlyWeekday,
      ),
    };
  }

  static DateTime _resolveWeekdayOfMonth(int year, int month, int ordinal, int weekday) {
    if (ordinal == -1) {
      var lastDayOfMonth = DateTime(year, month + 1, 0);
      var daysBack = (lastDayOfMonth.weekday - weekday) % DateTime.daysPerWeek;
      return lastDayOfMonth.subtract(Duration(days: daysBack));
    }

    var firstDayOfMonth = DateTime(year, month);
    var daysToWeekday = (weekday - firstDayOfMonth.weekday) % DateTime.daysPerWeek;
    var day = 1 + daysToWeekday + ((ordinal - 1) * DateTime.daysPerWeek);
    return DateTime(year, month, day);
  }

  static (int, int) _parseTime(String value) {
    var parts = value.split(':');
    if (parts.length != 2) return (8, 0);
    var h = int.tryParse(parts[0]) ?? 8;
    var m = int.tryParse(parts[1]) ?? 0;
    h = h.clamp(0, 23);
    m = m.clamp(0, 59);
    return (h, m);
  }

  static int _buildNotificationId(String seriesUuid, DateTime triggerLocal, Set<int> usedIds) {
    var salt = 0;
    while (true) {
      var hashInput = '$seriesUuid|${triggerLocal.toUtc().millisecondsSinceEpoch}|$salt';
      var id = _stableHash(hashInput) & 0x7fffffff;
      if (id == 0) {
        salt++;
        continue;
      }
      if (!usedIds.contains(id)) {
        return id;
      }
      salt++;
    }
  }

  static int _stableHash(String value) {
    var hash = 0x811C9DC5;
    for (var rune in value.runes) {
      hash ^= rune;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  static Future<void> _configureTimezone() async {
    tzdata.initializeTimeZones();
    String timeZoneName;
    try {
      timeZoneName = await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      timeZoneName = 'UTC';
      SimpleLogging.d('Could not read local timezone. Falling back to UTC.');
    }
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      SimpleLogging.d('Configured series notification timezone. timeZone=$timeZoneName');
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      SimpleLogging.d('Could not configure timezone "$timeZoneName". Falling back to UTC.');
    }
  }

  static String _buildSeriesSignature(SeriesDef seriesDef) {
    var settings = seriesDef.notificationSettingsReadonly();
    var payload = {
      'uuid': seriesDef.uuid,
      'name': seriesDef.name,
      'color': seriesDef.color.toARGB32(),
      'enabled': settings.enabled,
      'repeat': settings.repeatType.name,
      'dailyTimes': settings.dailyTimes,
      'time': settings.time,
      'interval': settings.everyXDaysInterval,
      'anchor': settings.everyXDaysAnchorUtcMs,
      'weekdays': settings.weeklyWeekdays,
      'monthlyRule': settings.monthlyRule.name,
      'monthlyDay': settings.monthlyDay,
      'monthlyWeekdayOrdinal': settings.monthlyWeekdayOrdinal,
      'monthlyWeekday': settings.monthlyWeekday,
    };
    return jsonEncode(payload);
  }

  static bool _isSupportedPlatform() {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.android;
  }
}
