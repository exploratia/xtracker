import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../app_info.dart';
import '../device_storage/device_storage.dart';
import '../stack/file_line_stack.dart';
import '../stack/stack_utils.dart';
import 'daily_files.dart';

class SimpleLogging {
  static const String _deviceStorageKey = 'logging';
  static const String separator = '--------------------------------------------------';
  static const String nl = '\n';

  static Level _logLevel = Level.info;
  static bool _useFullStack = false;

  static Level get logLevel {
    return _logLevel;
  }

  static set logLevel(Level logLevel) {
    _logLevel = logLevel;
    _store();
  }

  static bool get useFullStack {
    return _useFullStack;
  }

  static set useFullStack(bool useFullStack) {
    _useFullStack = useFullStack;
    _store();
  }

  static final logger = Logger(
    filter: _Filter(),
    level: Logger.level,
    printer: _Printer(),
    output: kDebugMode ? _LogOutputWithConsole() : _LogOutput(),
    // PrettyPrinter(
    //     methodCount: 1,
    //     // Number of method calls to be displayed
    //     errorMethodCount: 8,
    //     // Number of method calls if stacktrace is provided
    //     lineLength: 10,
    //     // Width of the output
    //     colors: false,
    //     // Colorful log messages
    //     printEmojis: false,
    //     // Print an emoji for each log message
    //     printTime: false // Should each log print contain a timestamp
    //     ),
  );

  /// Log a message at level [Level.debug].
  static void d(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.info].
  static void i(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.warning].
  static void w(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.w(message, time: time, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.error].
  static void e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logger.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  static List<Level> getKnownLevels() {
    return [Level.debug, Level.info, Level.warning, Level.error];
  }

  static void _store() async {
    try {
      final loggingData = {
        'logLevel': _logLevel.name,
        'fullStack': _useFullStack,
      };
      await DeviceStorage.write(_deviceStorageKey, jsonEncode(loggingData));
    } catch (err) {
      // await Dialogs.simpleOkDialog(err.toString(), context, title: 'Fehler');
    }
  }

  static Future<void> init() async {
    await AppInfo.init();
    await DailyFiles.init();

    final dataStr = await DeviceStorage.read(_deviceStorageKey);
    if (dataStr != null) {
      final data = jsonDecode(dataStr) as Map<String, dynamic>;
      if (data.containsKey('logLevel')) {
        final level = data['logLevel'] as String;
        _logLevel = getKnownLevels().firstWhere((element) => element.name == level, orElse: () => Level.warning);
      }
      if (data.containsKey('fullStack')) {
        _useFullStack = data['fullStack'] as bool;
      }
    }
  }
}

class _Printer extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    return [event.message.toString()];
  }
}

class _Filter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return (event.level.index >= SimpleLogging.logLevel.index);
  }
}

class _LogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    final fileLine = StackUtils.determineFileLine();
    var error = event.origin.error;

    // FileOutput
    _Outputs.outFile(event, fileLine, error);
  }
}

class _LogOutputWithConsole extends LogOutput {
  @override
  void output(OutputEvent event) {
    final fileLineAndStack = StackUtils.determineFileLine();
    var error = event.origin.error;

    _Outputs.outCons(event, fileLineAndStack, error);
    // FileOutput
    _Outputs.outFile(event, fileLineAndStack, error);
  }
}

class _Outputs {
  static final Map<Level, String> _levelMapping = {
    // Level.verbose: 'VERB ',
    Level.debug: 'DEBUG',
    Level.info: 'INFO ',
    Level.warning: 'WARN ',
    Level.error: 'ERROR',
    // Level.wtf: 'WTF  ',
  };

  static void outFile(OutputEvent event, FileLineStack fileLineAndStack, dynamic error) {
    String logMsg = '';
    for (var line in event.lines) {
      if (logMsg.isNotEmpty) logMsg += '\n';
      logMsg += line;
    }

    logMsg = '${_normalizedLevel(event.level)} | ${fileLineAndStack.toLogFileLine()} | $logMsg';
    if (error != null) {
      logMsg += '\n  Error:\n$error';
    }

    if (SimpleLogging.useFullStack && fileLineAndStack.stack != null && event.level.index >= Level.warning.index) {
      logMsg += '\n  Stack:\n${fileLineAndStack.stack}';
    }

    DailyFiles.writeToFile(logMsg, dateTime: event.origin.time);
  }

  static void outCons(OutputEvent event, FileLineStack fileLineAndStack, dynamic error) {
    bool first = true;
    for (var line in event.lines) {
      if (kDebugMode) {
        if (first) {
          first = false;
          print('${_normalizedLevel(event.level)} ${fileLineAndStack.toConsoleFileLine()} | $line');
        } else {
          print(line);
        }
      }
    }
    if (error != null) {
      if (kDebugMode) {
        print('  Error:');
        print(error);
      }
    }

    if (SimpleLogging.useFullStack && fileLineAndStack.stack != null && event.level.index >= Level.warning.index) {
      if (kDebugMode) {
        print('  Stack:');
        print(fileLineAndStack.stack);
      }
    }
  }

  static String _normalizedLevel(Level level) {
    return _levelMapping[level] ?? 'UNKNOWN';
  }
}
