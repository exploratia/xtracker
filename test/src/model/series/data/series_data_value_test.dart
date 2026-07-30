import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/series/data/blood_pressure/blood_pressure_value.dart';
import 'package:xtracker/src/model/series/data/custom/custom_value.dart';
import 'package:xtracker/src/model/series/data/daily_check/daily_check_value.dart';
import 'package:xtracker/src/model/series/data/daily_life/daily_life_value.dart';
import 'package:xtracker/src/model/series/data/habit/habit_value.dart';
import 'package:xtracker/src/model/series/data/monthly/monthly_value.dart';

void main() {
  group('SeriesDataValue.duplicateAt', () {
    final sourceDate = DateTime.utc(2025, 1, 2, 3, 4);
    final duplicateDate = DateTime.utc(2026, 5, 6, 7, 8);

    test('duplicates blood pressure data with a new identity', () {
      final source = BloodPressureValue('source', sourceDate, 120, 80, true);

      final duplicate = source.duplicateAt(duplicateDate) as BloodPressureValue;

      expect(duplicate.uuid, isNot(source.uuid));
      expect(duplicate.dateTime, duplicateDate);
      expect(duplicate.high, source.high);
      expect(duplicate.low, source.low);
      expect(duplicate.medication, source.medication);
    });

    test('duplicates daily-life data with a new identity', () {
      final source = DailyLifeValue('source', sourceDate, 'tag');

      final duplicate = source.duplicateAt(duplicateDate) as DailyLifeValue;

      expect(duplicate.uuid, isNot(source.uuid));
      expect(duplicate.dateTime, duplicateDate);
      expect(duplicate.tagId, source.tagId);
    });

    test('duplicates custom data without sharing its mutable values map', () {
      final source = CustomValue('source', sourceDate, {'value': 42}, 'tag');

      final duplicate = source.duplicateAt(duplicateDate) as CustomValue;

      expect(duplicate.uuid, isNot(source.uuid));
      expect(duplicate.dateTime, duplicateDate);
      expect(duplicate.values, source.values);
      expect(identical(duplicate.values, source.values), isFalse);
      expect(duplicate.tagId, source.tagId);
    });

    test('keeps the monthly runtime type', () {
      final source = MonthlyValue('source', sourceDate, {'value': 42}, null);

      final duplicate = source.duplicateAt(duplicateDate);

      expect(duplicate, isA<MonthlyValue>());
      expect(duplicate.uuid, isNot(source.uuid));
      expect(duplicate.dateTime, duplicateDate);
    });

    test('rejects habit and daily-check values', () {
      expect(
        () => HabitValue('habit', sourceDate).duplicateAt(duplicateDate),
        throwsUnsupportedError,
      );
      expect(
        () => DailyCheckValue('daily-check', sourceDate).duplicateAt(duplicateDate),
        throwsUnsupportedError,
      );
    });
  });
}
