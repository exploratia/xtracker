import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/model/changelog/change_log_entry.dart';

void main() {
  group('ChangeLog', () {
    test('registers every released version with localized release notes', () {
      final changelog = File('CHANGELOG.md').readAsStringSync();
      final releasedVersions = RegExp(r'^## \[([^\]]+)\]', multiLine: true).allMatches(changelog).map((match) => match.group(1)!).toList();
      final entriesByVersion = {for (final entry in ChangeLog.entries) entry.version: entry};

      expect(entriesByVersion.keys, containsAll(releasedVersions));
      expect(entriesByVersion.length, ChangeLog.entries.length);

      for (final locale in ['de-DE', 'en-US']) {
        final translations = jsonDecode(File('assets/translations/$locale.json').readAsStringSync()) as Map<String, dynamic>;
        for (final version in releasedVersions) {
          final entry = entriesByVersion[version]!;
          dynamic message = translations;
          for (final segment in entry.messageKey.split('.')) {
            message = (message as Map<String, dynamic>)[segment];
          }
          expect(message, isA<String>(), reason: '$locale release notes for $version');
          expect((message as String).trim(), isNotEmpty, reason: '$locale release notes for $version');
        }
      }
    });

    test('returns the 2.2.2 patch entry after 2.2.1', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '2.2.1',
        currentVersion: '2.2.2',
      );

      expect(entries.map((entry) => entry.version), ['2.2.2']);
    });

    test('returns the 2.2.3 patch entry after 2.2.2', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '2.2.2',
        currentVersion: '2.2.3',
      );

      expect(entries.map((entry) => entry.version), ['2.2.3']);
    });

    test('returns the 2.2.4 patch entry after 2.2.3', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '2.2.3',
        currentVersion: '2.2.4',
      );

      expect(entries.map((entry) => entry.version), ['2.2.4']);
    });

    test('returns the 2.3.0 release entry after 2.2.4', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '2.2.4',
        currentVersion: '2.3.0',
      );

      expect(entries.map((entry) => entry.version), ['2.3.0']);
    });

    test('returns the 2.4.0 release entry after 2.3.0', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '2.3.0',
        currentVersion: '2.4.0',
      );

      expect(entries.map((entry) => entry.version), ['2.4.0']);
    });

    test('returns entries between previous and current version', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '1.2.0',
        currentVersion: '1.4.0',
      );

      expect(entries.map((entry) => entry.version), ['1.4.0', '1.3.1', '1.3.0', '1.2.1']);
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

    test('returns all entries up to current release after 2.0.0', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '2.0.0',
        currentVersion: '2.2.1',
      );

      expect(entries.map((entry) => entry.version), ['2.2.1', '2.2.0', '2.1.0', '2.0.1']);
    });

    test('returns only patch entry after affected 2.2.0 release', () {
      final entries = ChangeLog.entriesBetween(
        previousVersion: '2.2.0',
        currentVersion: '2.2.1',
      );

      expect(entries.map((entry) => entry.version), ['2.2.1']);
    });
  });
}
