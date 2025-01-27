library flutter_simple_logging;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../app_info.dart';
import '../device_storage/device_storage.dart';
import 'daily_files.dart';

class SimpleLogging {
  static const String _deviceStorageKey = 'logging';

  static Level _logLevel = Level.warning;
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
        _logLevel = getKnownLevels().firstWhere(
            (element) => element.name == level,
            orElse: () => Level.warning);
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
    final fileLine = _StackUtils.determineFileLine();
    var error = event.origin.error;

    // FileOutput
    _Outputs.outFile(event, fileLine, error);
  }
}

class _LogOutputWithConsole extends LogOutput {
  @override
  void output(OutputEvent event) {
    final fileLineAndStack = _StackUtils.determineFileLine();
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

  static void outFile(
      OutputEvent event, _FileLineAndStack fileLineAndStack, dynamic error) {
    String logMsg = '';
    for (var line in event.lines) {
      if (logMsg.isNotEmpty) logMsg += '\n';
      logMsg += line;
    }

    logMsg =
        '${_normalizedLevel(event.level)} | ${fileLineAndStack.fileLine} $logMsg';
    if (error != null) {
      logMsg += '\n  Error:\n$error';
    }

    if (fileLineAndStack.stack != null &&
        event.level.index >= Level.warning.index) {
      logMsg += '\n  Stack:\n${fileLineAndStack.stack}';
    }

    DailyFiles.writeToFile(logMsg, dateTime: event.origin.time);
  }

  static void outCons(
      OutputEvent event, _FileLineAndStack fileLineAndStack, dynamic error) {
    bool first = true;
    for (var line in event.lines) {
      if (kDebugMode) {
        if (first) {
          first = false;
          print(
              '${_normalizedLevel(event.level)} ${fileLineAndStack.fileLine} $line');
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

    if (fileLineAndStack.stack != null &&
        event.level.index >= Level.warning.index) {
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

class _StackUtils {
  static final packageName = AppInfo.projectName;

  static _FileLineAndStack determineFileLine() {
    // print(StackTrace.current);
    final stack = StackTrace.current
        .toString()
        .replaceAll('<anonymous closure>', '')
        .replaceAll('<asynchronous suspension>', '')
        .split('\n')
        .where((line) =>
            !line.contains('package:logger') &&
            !line.contains(
                'package:flutter_simple_logging/flutter_simple_logging') &&
            line.trim().isNotEmpty)
        .where((line) {
          // FullStack? Dann immer True
          if (SimpleLogging.useFullStack) return true;
          // Sonst nur packageName erlauben
          return line.contains('package:$packageName/') ||
              line.contains('package:flutter_simple_logging/widgets/logs_view');
        }) // ist das gut? wg. Fremdpaketen evtl.?
        .map((line) => line.substring(line.indexOf(' ')).trimLeft())
        .toList();

    if (stack.isEmpty) return _FileLineAndStack('-?-', null);

    String fileLine = stack.first;
    // fileLine = fileLine.substring(fileLine.indexOf('('));
    // man koennte noch den standard-Package-Pfad kuerzen, aber dann kann man in der Console beim Debug nicht mehr klicken :(
    //.replaceFirst('package:$packageName', '..');

    final String? s = stack.length > 1 ? stack.join('\n') : null;

    return _FileLineAndStack(fileLine, s);
  }
}

class _FileLineAndStack {
  final String fileLine;
  final String? stack;

  _FileLineAndStack(this.fileLine, this.stack);
}
