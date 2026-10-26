import 'dart:math' as math;
import 'dart:ui';

/// Maps a drag from a fixed origin to bounded calendar or clock offsets.
class DateTimeScrub {
  /// Creates a gesture whose extrema lie on [bounds], just inside the screen.
  const DateTimeScrub({
    required this.initialValue,
    required this.origin,
    required this.bounds,
    required this.isTime,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialValue;
  final Offset origin;
  final Rect bounds;
  final bool isTime;
  final DateTime firstDate;
  final DateTime lastDate;

  /// Returns a preview relative to the original value, never the previous move.
  DateTime valueAt(Offset position) {
    final vertical = _offset(origin.dy - position.dy, origin.dy - bounds.top, bounds.bottom - origin.dy, 12);
    final minutes = isTime ? _offset(position.dx - origin.dx, bounds.right - origin.dx, origin.dx - bounds.left, 30) : 0;
    if (vertical == 0 && minutes == 0) return initialValue;
    // Calendar arithmetic preserves the wall-clock time across daylight saving
    // changes. Clock adjustments naturally carry over into the adjacent date.
    final value = isTime
        ? initialValue.copyWith(hour: initialValue.hour + vertical, minute: initialValue.minute + minutes)
        : initialValue.copyWith(day: initialValue.day + vertical);
    final day = DateTime(value.year, value.month, value.day);
    if (day.isBefore(firstDate)) {
      return initialValue.copyWith(
        year: firstDate.year,
        month: firstDate.month,
        day: firstDate.day,
        hour: isTime ? 0 : initialValue.hour,
        minute: isTime ? 0 : initialValue.minute,
        second: isTime ? 0 : initialValue.second,
        millisecond: isTime ? 0 : initialValue.millisecond,
        microsecond: isTime ? 0 : initialValue.microsecond,
      );
    }
    if (day.isAfter(lastDate)) {
      return initialValue.copyWith(
        year: lastDate.year,
        month: lastDate.month,
        day: lastDate.day,
        hour: isTime ? 23 : initialValue.hour,
        minute: isTime ? 59 : initialValue.minute,
        second: isTime ? 59 : initialValue.second,
        millisecond: isTime ? 999 : initialValue.millisecond,
        microsecond: isTime ? 999 : initialValue.microsecond,
      );
    }
    return value;
  }

  int _offset(double distance, double positiveExtent, double negativeExtent, int limit) {
    // A small neutral area makes it easy to return to the starting value.
    const deadZone = 8.0;
    if (distance.abs() <= deadZone) return 0;
    final extent = math.max(deadZone + 1, distance > 0 ? positiveExtent : negativeExtent);
    final fraction = ((distance.abs() - deadZone) / (extent - deadZone)).clamp(0.0, 1.0);
    return (fraction * limit).round() * distance.sign.toInt();
  }
}
