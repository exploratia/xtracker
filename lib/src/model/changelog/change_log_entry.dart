class ChangeLogEntry {
  final String version;
  final String messageKey;

  const ChangeLogEntry({
    required this.version,
    required this.messageKey,
  });
}

class ChangeLog {
  static const entries = [
    ChangeLogEntry(
      version: '1.4.0',
      messageKey: 'changeLog.entries.v1_4_0',
    ),
    ChangeLogEntry(
      version: '1.3.1',
      messageKey: 'changeLog.entries.v1_3_1',
    ),
    ChangeLogEntry(
      version: '1.3.0',
      messageKey: 'changeLog.entries.v1_3_0',
    ),
    ChangeLogEntry(
      version: '1.2.0',
      messageKey: 'changeLog.entries.v1_2_0',
    ),
    ChangeLogEntry(
      version: '1.1.0',
      messageKey: 'changeLog.entries.v1_1_0',
    ),
    ChangeLogEntry(
      version: '1.0.0',
      messageKey: 'changeLog.entries.v1_0_0',
    ),
  ];

  static List<ChangeLogEntry> entriesBetween({
    required String? previousVersion,
    required String currentVersion,
  }) {
    if (previousVersion == null || previousVersion == currentVersion) return [];

    final previous = _ComparableVersion.tryParse(previousVersion);
    final current = _ComparableVersion.tryParse(currentVersion);
    if (previous == null || current == null || previous.compareTo(current) >= 0) return [];

    final matchingEntries = entries.where((entry) {
      final entryVersion = _ComparableVersion.tryParse(entry.version);
      if (entryVersion == null) return false;
      return entryVersion.compareTo(previous) > 0 && entryVersion.compareTo(current) <= 0;
    }).toList();

    matchingEntries.sort((left, right) {
      final leftVersion = _ComparableVersion.tryParse(left.version)!;
      final rightVersion = _ComparableVersion.tryParse(right.version)!;
      return rightVersion.compareTo(leftVersion);
    });
    return matchingEntries;
  }
}

class _ComparableVersion implements Comparable<_ComparableVersion> {
  final List<int> parts;

  const _ComparableVersion(this.parts);

  static _ComparableVersion? tryParse(String version) {
    final parts = <int>[];
    for (final part in version.split(RegExp(r'[.+-]'))) {
      final match = RegExp(r'^\d+').firstMatch(part);
      if (match == null) continue;
      parts.add(int.parse(match.group(0)!));
    }
    if (parts.isEmpty) return null;
    return _ComparableVersion(parts);
  }

  @override
  int compareTo(_ComparableVersion other) {
    final maxLength = parts.length > other.parts.length ? parts.length : other.parts.length;
    for (var i = 0; i < maxLength; i++) {
      final left = i < parts.length ? parts[i] : 0;
      final right = i < other.parts.length ? other.parts[i] : 0;
      final compare = left.compareTo(right);
      if (compare != 0) return compare;
    }
    return 0;
  }
}
