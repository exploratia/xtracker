import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/date_time_utils.dart';

void main() {
  group('Date Time Utils', () {
    test('test isMonthStart', () {
      expect(false, DateTimeUtils.isMonthStart(DateTime(2025, 8, 30)));
      expect(true, DateTimeUtils.isMonthStart(DateTime(2025, 9, 1)));
    });

    test('test isMonthEnd', () {
      expect(false, DateTimeUtils.isMonthEnd(DateTime(2025, 8, 30)));
      expect(true, DateTimeUtils.isMonthEnd(DateTime(2025, 8, 31)));
      expect(false, DateTimeUtils.isMonthEnd(DateTime(2025, 9, 1)));
      expect(true, DateTimeUtils.isMonthEnd(DateTime(2025, 9, 30)));
      expect(true, DateTimeUtils.isMonthEnd(DateTime(2025, 2, 28)));
      expect(false, DateTimeUtils.isMonthEnd(DateTime(2024, 2, 28)));
      expect(true, DateTimeUtils.isMonthEnd(DateTime(2024, 2, 29)));
    });

    test('test mondayOfSameWeek', () {
      var datetime = DateTimeUtils.mondayOfSameWeek(DateTime(2025, 8, 31));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(25, datetime.day);
      datetime = DateTimeUtils.mondayOfSameWeek(DateTime(2025, 8, 25));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(25, datetime.day);
      datetime = DateTimeUtils.mondayOfSameWeek(DateTime(2025, 9, 2));
      expect(2025, datetime.year);
      expect(9, datetime.month);
      expect(1, datetime.day);
    });

    test('test firstDayOfMonth', () {
      var datetime = DateTimeUtils.firstDayOfMonth(DateTime(2025, 8, 31));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfMonth(DateTime(2025, 8, 25));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfMonth(DateTime(2025, 9, 2));
      expect(2025, datetime.year);
      expect(9, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfMonth(DateTime(2025, 2, 2));
      expect(2025, datetime.year);
      expect(2, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfMonth(DateTime(2024, 2, 2));
      expect(2024, datetime.year);
      expect(2, datetime.month);
      expect(1, datetime.day);
    });

    test('test lastDayOfMonth', () {
      var datetime = DateTimeUtils.lastDayOfMonth(DateTime(2025, 8, 31));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(31, datetime.day);
      datetime = DateTimeUtils.lastDayOfMonth(DateTime(2025, 8, 25));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(31, datetime.day);
      datetime = DateTimeUtils.lastDayOfMonth(DateTime(2025, 9, 2));
      expect(2025, datetime.year);
      expect(9, datetime.month);
      expect(30, datetime.day);
      datetime = DateTimeUtils.lastDayOfMonth(DateTime(2025, 2, 2));
      expect(2025, datetime.year);
      expect(2, datetime.month);
      expect(28, datetime.day);
      datetime = DateTimeUtils.lastDayOfMonth(DateTime(2024, 2, 2));
      expect(2024, datetime.year);
      expect(2, datetime.month);
      expect(29, datetime.day);
    });

    test('test firstDayOfNextMonth', () {
      var datetime = DateTimeUtils.firstDayOfNextMonth(DateTime(2025, 8, 31));
      expect(2025, datetime.year);
      expect(9, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfNextMonth(DateTime(2025, 8, 25));
      expect(2025, datetime.year);
      expect(9, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfNextMonth(DateTime(2025, 9, 1));
      expect(2025, datetime.year);
      expect(10, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfNextMonth(DateTime(2025, 2, 2));
      expect(2025, datetime.year);
      expect(3, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfNextMonth(DateTime(2024, 1, 2));
      expect(2024, datetime.year);
      expect(2, datetime.month);
      expect(1, datetime.day);
    });

    test('test firstDayOfPreviousMonth', () {
      var datetime = DateTimeUtils.firstDayOfPreviousMonth(DateTime(2025, 8, 31));
      expect(2025, datetime.year);
      expect(7, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfPreviousMonth(DateTime(2025, 8, 25));
      expect(2025, datetime.year);
      expect(7, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfPreviousMonth(DateTime(2025, 9, 1));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfPreviousMonth(DateTime(2025, 2, 2));
      expect(2025, datetime.year);
      expect(1, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfPreviousMonth(DateTime(2024, 1, 2));
      expect(2023, datetime.year);
      expect(12, datetime.month);
      expect(1, datetime.day);
    });

    test('test firstDayOfYear', () {
      var datetime = DateTimeUtils.firstDayOfYear(DateTime(2025, 8, 31));
      expect(2025, datetime.year);
      expect(1, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfYear(DateTime(2025, 8, 25));
      expect(2025, datetime.year);
      expect(1, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfYear(DateTime(2025, 9, 1));
      expect(2025, datetime.year);
      expect(1, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfYear(DateTime(2025, 2, 2));
      expect(2025, datetime.year);
      expect(1, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.firstDayOfYear(DateTime(2024, 1, 2));
      expect(2024, datetime.year);
      expect(1, datetime.month);
      expect(1, datetime.day);
    });

    test('test dayBefore', () {
      var datetime = DateTimeUtils.dayBefore(DateTime(2025, 8, 31));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(30, datetime.day);
      datetime = DateTimeUtils.dayBefore(DateTime(2025, 8, 25));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(24, datetime.day);
      datetime = DateTimeUtils.dayBefore(DateTime(2025, 9, 1));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(31, datetime.day);
      datetime = DateTimeUtils.dayBefore(DateTime(2025, 3, 1));
      expect(2025, datetime.year);
      expect(2, datetime.month);
      expect(28, datetime.day);
      datetime = DateTimeUtils.dayBefore(DateTime(2024, 3, 1));
      expect(2024, datetime.year);
      expect(2, datetime.month);
      expect(29, datetime.day);
    });

    test('test dayAfter', () {
      var datetime = DateTimeUtils.dayAfter(DateTime(2025, 8, 31));
      expect(2025, datetime.year);
      expect(9, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.dayAfter(DateTime(2025, 8, 25));
      expect(2025, datetime.year);
      expect(8, datetime.month);
      expect(26, datetime.day);
      datetime = DateTimeUtils.dayAfter(DateTime(2025, 2, 28));
      expect(2025, datetime.year);
      expect(3, datetime.month);
      expect(1, datetime.day);
      datetime = DateTimeUtils.dayAfter(DateTime(2024, 2, 28));
      expect(2024, datetime.year);
      expect(2, datetime.month);
      expect(29, datetime.day);
      datetime = DateTimeUtils.dayAfter(DateTime(2024, 2, 29));
      expect(2024, datetime.year);
      expect(3, datetime.month);
      expect(1, datetime.day);
    });

    test('test truncateToDay', () {
      var now = DateTime.now();
      var datetime = DateTimeUtils.truncateToDay(now);
      expect(0, datetime.hour);
      expect(0, datetime.minute);
      expect(0, datetime.second);
      expect(0, datetime.millisecond);
      expect(0, datetime.microsecond);
    });
  });
}
