import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/changelog/change_log_entry.dart';

void main() {
  group('ChangeLog', () {
    test('returns entries between previous and current version', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '1.2.0',
        currentVersion: '1.4.0',
      );

      expect(entries.map((entry) => entry.version), ['1.4.0', '1.3.1', '1.3.0']);
    });

    test('returns no entries for first app start', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: null,
        currentVersion: '1.4.0',
      );

      expect(entries, isEmpty);
    });

    test('returns 2.0.0 entry after 1.4.0', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '1.4.0',
        currentVersion: '2.0.0',
      );

      expect(entries.map((entry) => entry.version), ['2.0.0']);
    });

    test('returns entries for current release after 2.0.0', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '2.0.0',
        currentVersion: '2.1.0',
      );

      expect(entries.map((entry) => entry.version), ['2.1.0', '2.0.1']);
    });
  });
}
