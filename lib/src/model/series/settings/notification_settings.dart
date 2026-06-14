import 'series_settings.dart';

enum NotificationRepeatType {
  daily,
  everyXDays,
  weekly,
  monthly;

  static NotificationRepeatType byNameOrDefault(String? raw) {
    for (var value in NotificationRepeatType.values) {
      if (value.name == raw) return value;
    }
    return NotificationRepeatType.daily;
  }
}

enum NotificationMonthlyRule {
  dayOfMonth,
  lastDay,
  weekdayOfMonth;

  static NotificationMonthlyRule byNameOrDefault(String? raw) {
    for (var value in NotificationMonthlyRule.values) {
      if (value.name == raw) return value;
    }
    return NotificationMonthlyRule.dayOfMonth;
  }
}

class NotificationSettings extends SeriesSettings {
  static const String _prefix = 'notification';

  static const String _enabled = 'Enabled';
  static const String _repeatType = 'RepeatType';
  static const String _dailyTimes = 'DailyTimes';
  static const String _time = 'Time';
  static const String _everyXDaysInterval = 'EveryXDaysInterval';
  static const String _everyXDaysAnchorUtcMs = 'EveryXDaysAnchorUtcMs';
  static const String _weeklyWeekdays = 'WeeklyWeekdays';
  static const String _monthlyRule = 'MonthlyRule';
  static const String _monthlyDay = 'MonthlyDay';
  static const String _monthlyWeekdayOrdinal = 'MonthlyWeekdayOrdinal';
  static const String _monthlyWeekday = 'MonthlyWeekday';

  /// [updateStateCB] optional callback which is called when the settings map is changed. If not set readonly.
  NotificationSettings(Map<String, dynamic> settings, Function()? updateStateCB) : super(_prefix, settings, updateStateCB);

  bool get enabled => getBool(_enabled);

  set enabled(bool value) {
    set(_enabled, value == true ? true : null);
  }

  NotificationRepeatType get repeatType => NotificationRepeatType.byNameOrDefault(optString(_repeatType));

  set repeatType(NotificationRepeatType value) {
    set(_repeatType, value == NotificationRepeatType.daily ? null : value.name);
  }

  List<String> get dailyTimes {
    return getList(_dailyTimes).whereType<String>().map((time) => time.trim()).where((time) => _isValidTimeValue(time)).toSet().toList()..sort();
  }

  set dailyTimes(List<String> value) {
    var normalized = value.map((time) => time.trim()).where((time) => _isValidTimeValue(time)).toSet().toList()..sort();
    set(_dailyTimes, normalized.isEmpty ? null : normalized);
  }

  String get time {
    var value = getString(_time, defaultValue: '08:00');
    if (_isValidTimeValue(value)) {
      return value;
    }
    return '08:00';
  }

  set time(String value) {
    var trimmed = value.trim();
    set(_time, trimmed == '08:00' ? null : trimmed);
  }

  int get everyXDaysInterval {
    var interval = getInt(_everyXDaysInterval, defaultValue: 1);
    if (interval < 1) return 1;
    if (interval > 365) return 365;
    return interval;
  }

  set everyXDaysInterval(int value) {
    var normalized = value.clamp(1, 365);
    set(_everyXDaysInterval, normalized == 1 ? null : normalized);
  }

  int? get everyXDaysAnchorUtcMs {
    return get(_everyXDaysAnchorUtcMs) as int?;
  }

  set everyXDaysAnchorUtcMs(int? value) {
    set(_everyXDaysAnchorUtcMs, value);
  }

  List<int> get weeklyWeekdays {
    var values = getList(_weeklyWeekdays).whereType<int>().where((weekday) => weekday >= DateTime.monday && weekday <= DateTime.sunday).toSet().toList()
      ..sort();
    if (values.isEmpty) {
      return [DateTime.monday];
    }
    return values;
  }

  set weeklyWeekdays(List<int> values) {
    var normalized = values.where((weekday) => weekday >= DateTime.monday && weekday <= DateTime.sunday).toSet().toList()..sort();
    if (normalized.isEmpty) {
      normalized = [DateTime.monday];
    }
    set(_weeklyWeekdays, normalized.length == 1 && normalized.first == DateTime.monday ? null : normalized);
  }

  NotificationMonthlyRule get monthlyRule => NotificationMonthlyRule.byNameOrDefault(optString(_monthlyRule));

  set monthlyRule(NotificationMonthlyRule value) {
    set(_monthlyRule, value == NotificationMonthlyRule.dayOfMonth ? null : value.name);
  }

  int get monthlyDay {
    var day = getInt(_monthlyDay, defaultValue: 1);
    if (day < 1) return 1;
    if (day > 31) return 31;
    return day;
  }

  set monthlyDay(int value) {
    var normalized = value.clamp(1, 31);
    set(_monthlyDay, normalized == 1 ? null : normalized);
  }

  int get monthlyWeekdayOrdinal {
    var ordinal = getInt(_monthlyWeekdayOrdinal, defaultValue: 1);
    if (ordinal == -1 || (ordinal >= 1 && ordinal <= 3)) {
      return ordinal;
    }
    return 1;
  }

  set monthlyWeekdayOrdinal(int value) {
    var normalized = value == -1 || (value >= 1 && value <= 3) ? value : 1;
    set(_monthlyWeekdayOrdinal, normalized == 1 ? null : normalized);
  }

  int get monthlyWeekday {
    var weekday = getInt(_monthlyWeekday, defaultValue: DateTime.monday);
    if (weekday >= DateTime.monday && weekday <= DateTime.sunday) {
      return weekday;
    }
    return DateTime.monday;
  }

  set monthlyWeekday(int value) {
    var normalized = value.clamp(DateTime.monday, DateTime.sunday);
    set(_monthlyWeekday, normalized == DateTime.monday ? null : normalized);
  }

  static bool isValidTimeValue(String value) => _isValidTimeValue(value);

  static bool _isValidTimeValue(String value) {
    final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(value.trim());
    return match != null;
  }
}
