// lib/src/util/logging/daily_files_web.dart
import 'package:flutter/foundation.dart';

import '../ex.dart';

class DailyFiles {
  static Future<void> init() async {
    if (kDebugMode) {
      print('[DailyFiles] Web: file logging disabled, console only.');
    }
  }

  static Future<List<String>> listLogFileNames() async {
    // Keine Files auf Web – UI kann damit umgehen und „keine Logs“ anzeigen.
    return <String>[];
  }

  static Future<List<String>> listTmpFileNames() async {
    return <String>[];
  }

  static bool logsDirAvailable() => false;

  static void writeToFile(String value, {DateTime? dateTime}) {
    // Auf Web loggen wir in der Debug-Konsole, wenn möglich.
    if (kDebugMode) {
      final ts = dateTime?.toIso8601String() ?? '';
      final prefix = ts.isNotEmpty ? '[$ts] ' : '';
      print('$prefix$value');
    }
  }

  static Future<String> readLog(String filename, bool addNLAfterLogLevel) async {
    return 'Logging to files is not available on Web.';
  }

  static Future<List<String>> readLogLines(String filename, bool addNLAfterLogLevel) async {
    return <String>['Logging to files is not available on Web.'];
  }

  static String getFullLogPath(String filename) {
    throw Ex('No logs dir on Web.');
  }

  static Future<void> deleteLog(String filename) async {
    // No-op
  }

  static Future<void> deleteAllLogs() async {
    // No-op
  }

  static Future<dynamic> zipAllLogs() async {
    throw Ex('Zipping logs is not available on Web.');
  }
}
