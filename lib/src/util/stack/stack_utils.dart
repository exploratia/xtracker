import 'file_line_stack.dart';

class StackUtils {
  static String projectName = "unset";

  /*
   * examples:
   * package:xtracker/src/widgets/administration/logging/log_settings_view.dart:58:41  (Android emulator)
   * package:xtracker/src/widgets/administration/logging/log_settings_view.dart 58:41  (Chrome)
   * package:xtracker/src/widgets/administration/logging/log_settings_1view.dart:58    (real device)
  */

  static final regexBetweenBrackets = RegExp(r'\((.*?)\)');
  static final regexFile = RegExp(r'(package:(.+\.dart))');
  static final regexLine = RegExp(r'dart:(\d+)|dart (\d+)');

  static void init(String projectName) {
    StackUtils.projectName = projectName;
  }

  static FileLineStack determineFileLine() {
    // print(StackTrace.current);
    var currentStackTrace = StackTrace.current.toString();
    return determineFileLineAndStack(currentStackTrace);
  }

  static FileLineStack determineFileLineAndStack(String stackTrace) {
    var currentStackTraceLines = stackTrace.replaceAll('<anonymous closure>', '').replaceAll('<asynchronous suspension>', '').split('\n');
    var cleanedStackTraceLines = currentStackTraceLines
        .where((line) => !line.contains('package:logger') && !line.contains('flutter_simple_logging.dart') && line.trim().isNotEmpty)
        .toList();

    // remove ' <fn>' ?: .map((line) => line.substring(0, line.indexOf(' ')).trim()).toList();

    var ownPackageStackTraceLines = cleanedStackTraceLines.where((line) {
      return line.contains('package:$projectName/') || line.contains('package:flutter_simple_logging/widgets/logs_view');
    }).toList();

    final String? stackStr = cleanedStackTraceLines.isNotEmpty ? cleanedStackTraceLines.join('\n') : null;

    String fileName = '-?-';
    String fileFullName = '-?-';
    String lineNo = '-?-';

    if (ownPackageStackTraceLines.isNotEmpty) {
      String firstStackLine = ownPackageStackTraceLines.first;
      final matchBetweenBrackets = regexBetweenBrackets.firstMatch(firstStackLine);
      if (matchBetweenBrackets != null) {
        firstStackLine = matchBetweenBrackets.group(1)!;
      }
      final matchFile = regexFile.firstMatch(firstStackLine);
      if (matchFile != null) {
        String? str = matchFile.group(1); // Path to file
        if (str != null) {
          fileFullName = str;
          fileName = str.split('/').last;
        }
      }
      final matchLine = regexLine.firstMatch(firstStackLine);
      if (matchLine != null) {
        String? str = matchLine.group(1) ?? matchLine.group(2); // in case of (chrome) group 1 is null
        if (str != null) {
          lineNo = str;
        }
      }
    }

    return FileLineStack(fileName, fileFullName, lineNo, stackStr);
  }
}
