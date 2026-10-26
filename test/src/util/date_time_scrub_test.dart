import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/date_time_scrub.dart';

void main() {
  final initial = DateTime(2026, 10, 26, 14, 45, 12, 34, 56);
  const origin = Offset(150, 300);
  const bounds = Rect.fromLTRB(24, 24, 376, 776);

  DateTimeScrub scrub({bool isTime = false, DateTime? value, Offset start = origin}) => DateTimeScrub(
    initialValue: value ?? initial,
    origin: start,
    bounds: bounds,
    isTime: isTime,
    firstDate: DateTime(2000),
    lastDate: DateTime(2036, 12, 31),
  );

  test('origin and small movements preserve the exact starting value', () {
    for (final isTime in [false, true]) {
      expect(scrub(isTime: isTime).valueAt(origin), same(initial));
      expect(scrub(isTime: isTime).valueAt(origin + const Offset(7, -7)), same(initial));
    }
  });

  test('vertical date movement reaches twelve calendar days at each edge', () {
    expect(scrub().valueAt(const Offset(150, 24)), initial.copyWith(day: initial.day + 12));
    expect(scrub().valueAt(const Offset(150, 776)), initial.copyWith(day: initial.day - 12));
    expect(scrub().valueAt(const Offset(150, -100)), initial.copyWith(day: initial.day + 12));
    expect(scrub().valueAt(const Offset(150, 1000)), initial.copyWith(day: initial.day - 12));
    expect(scrub().valueAt(const Offset(376, 300)), initial);
  });

  test('each direction scales independently to its available screen distance', () {
    expect(scrub().valueAt(const Offset(150, 162)), initial.copyWith(day: initial.day + 6));
    expect(scrub().valueAt(const Offset(150, 538)), initial.copyWith(day: initial.day - 6));
  });

  test('clock axes combine hours and minutes and carry across midnight', () {
    expect(scrub(isTime: true).valueAt(const Offset(376, 24)), DateTime(2026, 10, 27, 3, 15, 12, 34, 56));
    expect(scrub(isTime: true).valueAt(const Offset(24, 776)), DateTime(2026, 10, 26, 2, 15, 12, 34, 56));
    expect(scrub(isTime: true).valueAt(const Offset(376, 300)), initial.copyWith(minute: 75));
    expect(scrub(isTime: true).valueAt(const Offset(24, 300)), initial.copyWith(minute: 15));
  });

  test('movement is absolute and returning to the origin resets the preview', () {
    final gesture = scrub(isTime: true);
    gesture.valueAt(const Offset(376, 24));
    expect(gesture.valueAt(origin), initial);
    expect(gesture.valueAt(const Offset(24, 300)), initial.copyWith(minute: 15));
  });

  test('date bounds preserve the clock and time bounds stop at midnight', () {
    final first = DateTime(2000, 1, 1, 1, 15);
    expect(scrub(value: first).valueAt(const Offset(150, 776)), first);
    expect(scrub(value: first, isTime: true).valueAt(const Offset(24, 776)), DateTime(2000));
    final last = DateTime(2036, 12, 31, 23, 30);
    expect(scrub(value: last).valueAt(const Offset(150, 24)), last);
    expect(scrub(value: last, isTime: true).valueAt(const Offset(376, 24)), DateTime(2036, 12, 31, 23, 59, 59, 999, 999));
  });

  test('origins near screen edges still produce bounded offsets', () {
    final gesture = scrub(start: const Offset(24, 24));
    expect(gesture.valueAt(const Offset(24, 0)), initial.copyWith(day: initial.day + 12));
    expect(gesture.valueAt(const Offset(24, 776)), initial.copyWith(day: initial.day - 12));
  });

  test('calendar movement retains UTC and handles month and year boundaries', () {
    final value = DateTime.utc(2026, 12, 31, 23, 45);
    expect(scrub(value: value).valueAt(const Offset(150, 24)), DateTime.utc(2027, 1, 12, 23, 45));
    expect(scrub(value: value, isTime: true).valueAt(const Offset(376, 24)), DateTime.utc(2027, 1, 1, 12, 15));
  });
}
