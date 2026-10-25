import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:xtracker/src/model/series/series_def.dart';
import 'package:xtracker/src/model/series/series_type.dart';
import 'package:xtracker/src/model/series/settings/notification_settings.dart';
import 'package:xtracker/src/util/app_series_notifications.dart';

void main() {
  late tz.Location berlin;
  late SeriesDef series;
  late NotificationSettings settings;

  setUpAll(() {
    tzdata.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  setUp(() {
    series = SeriesDef(uuid: 'reminder', seriesType: SeriesType.bloodPressure, seriesItems: []);
    settings = series.notificationSettingsEditable(() {});
    settings.enabled = true;
    settings.dailyTimes = ['06:30', '12:00', '18:30'];
    settings.time = '06:30';
  });

  for (final (month, day) in [(3, 29), (10, 25)]) {
    group('Berlin clock change on 2026-$month-$day', () {
      for (final startDay in [day - 1, day]) {
        test('daily reminders keep three distinct times per calendar day starting on $startDay', () {
          final now = tz.TZDateTime(berlin, 2026, month, startDay);
          final actual = AppSeriesNotifications.scheduledNotificationTimes(series, now: now);
          final expected = [
            for (var offset = 0; offset < 6; offset++)
              for (final (hour, minute) in [(6, 30), (12, 0), (18, 30)]) tz.TZDateTime(berlin, 2026, month, startDay + offset, hour, minute),
          ];

          expect(actual, orderedEquals(expected));
          expect(actual.map((time) => time.millisecondsSinceEpoch).toSet(), hasLength(18));
        });
      }

      test('daily reminders exclude elapsed times on the transition day', () {
        final now = tz.TZDateTime(berlin, 2026, month, day, 12);
        final actual = AppSeriesNotifications.scheduledNotificationTimes(series, now: now);

        expect(actual.first, tz.TZDateTime(berlin, 2026, month, day, 18, 30));
        expect(actual, hasLength(16));
        expect(actual.every((time) => time.isAfter(now)), isTrue);
      });

      for (final interval in [1, 3]) {
        for (final anchorDay in [day - 7, day + 1]) {
          test('every $interval days keeps the local time with anchor day $anchorDay', () {
            settings.repeatType = NotificationRepeatType.everyXDays;
            settings.everyXDaysInterval = interval;
            settings.everyXDaysAnchorUtcMs = tz.TZDateTime(berlin, 2026, month, anchorDay).millisecondsSinceEpoch;
            final now = tz.TZDateTime(berlin, 2026, month, day - 1, 12);
            var firstDay = anchorDay;
            while (firstDay < day) {
              firstDay += interval;
            }

            final actual = AppSeriesNotifications.scheduledNotificationTimes(series, now: now);

            expect(
              actual,
              orderedEquals([
                for (var i = 0; i < 6; i++) tz.TZDateTime(berlin, 2026, month, firstDay + i * interval, 6, 30),
              ]),
            );
          });
        }
      }

      test('weekly reminders include each selected weekday once for six weeks', () {
        settings.repeatType = NotificationRepeatType.weekly;
        settings.weeklyWeekdays = [DateTime.sunday, DateTime.monday];
        final now = tz.TZDateTime(berlin, 2026, month, day - 1);

        final actual = AppSeriesNotifications.scheduledNotificationTimes(series, now: now);

        expect(
          actual,
          orderedEquals([
            for (var week = 0; week < 6; week++) ...[
              tz.TZDateTime(berlin, 2026, month, day + week * 7, 6, 30),
              tz.TZDateTime(berlin, 2026, month, day + week * 7 + 1, 6, 30),
            ],
          ]),
        );
      });

      test('monthly last weekday keeps its date and local time', () {
        settings.repeatType = NotificationRepeatType.monthly;
        settings.monthlyRule = NotificationMonthlyRule.weekdayOfMonth;
        settings.monthlyWeekdayOrdinal = -1;
        settings.monthlyWeekday = DateTime.sunday;
        final now = tz.TZDateTime(berlin, 2026, month, day - 1);

        final actual = AppSeriesNotifications.scheduledNotificationTimes(series, now: now);

        expect(actual.first, tz.TZDateTime(berlin, 2026, month, day, 6, 30));
        expect(actual, hasLength(6));
        expect(actual.every((time) => time.weekday == DateTime.sunday && time.hour == 6 && time.minute == 30), isTrue);
      });
    });
  }

  test('disabled notifications have no schedule', () {
    settings.enabled = false;

    expect(AppSeriesNotifications.scheduledNotificationTimes(series, now: tz.TZDateTime(berlin, 2026, 10, 25)), isEmpty);
  });
}
