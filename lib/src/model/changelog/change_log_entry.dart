class ChangeLogEntry {
  final String version;
  final String message;

  const ChangeLogEntry({
    required this.version,
    required this.message,
  });
}

class ChangeLog {
  static const entries = [
    ChangeLogEntry(
      version: '1.0.0',
      message: 'Erste getestete Version mit Tages-Check, Blutdruck, Import/Export, Tabellen, Diagrammen und Pixelansicht.',
    ),
    ChangeLogEntry(
      version: '1.1.0',
      message: 'Neue Gewohnheiten, flexiblere Tabellenansichten und erste Erinnerungen fuer Backup und App-Unterstuetzung.',
    ),
    ChangeLogEntry(
      version: '1.2.0',
      message: 'Neue Analysen fuer aufgezeichnete Tage sowie Trend-Analysen fuer Blutdruck und Gewohnheiten.',
    ),
    ChangeLogEntry(
      version: '1.3.0',
      message: 'Taegliches Leben als neue Messreihe, Standardansichten pro Messreihe und Hintergrundbild-Unterstuetzung.',
    ),
    ChangeLogEntry(
      version: '1.3.1',
      message: 'Erweiterte Auswertungen fuer Tageszeiten und Monatsverteilungen.',
    ),
    ChangeLogEntry(
      version: '1.4.0',
      message: 'Erste oeffentliche Release-Version mit vereinheitlichter Pixelansicht.',
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

    return entries.where((entry) {
      final entryVersion = _ComparableVersion.tryParse(entry.version);
      if (entryVersion == null) return false;
      return entryVersion.compareTo(previous) > 0 && entryVersion.compareTo(current) <= 0;
    }).toList();
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
