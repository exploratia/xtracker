import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../app_info.dart';

/// Logging is not working in web!
class DailyFiles {
  static Directory? _appDocumentsDir;
  static Directory? _tmpDir;
  static Directory? _logsDir;
  static String _todayLog = '';

  /// Keep logs for 32 days. Afterwards delete them.
  static const _keepLogsForDays = 32;

  static final List<_MsgQueueItem> _msgQueue = [];
  static bool _timerSet = false;

  static Future<void> init() async {
    if (kIsWeb) {
      if (kDebugMode) {
        print('In web there is no app documents dir! Only console logging...');
      }
    } else {
      try {
        _appDocumentsDir = await getApplicationDocumentsDirectory();
        _tmpDir = await getTemporaryDirectory();
      } catch (err) {
        if (kDebugMode) {
          print('Failed to get app documents dir! Started in browser?\n $err');
        }
      }
    }
    if (_appDocumentsDir == null) {
      await _writeLogStart();
      return;
    }
    final appDocDir = _appDocumentsDir!;
    var logsDir = Directory('${appDocDir.path}/logs');
    if (!(await logsDir.exists())) logsDir = await logsDir.create();
    _logsDir = logsDir;

    await _writeLogStart();

    try {
      await _clearOldLogs();
    } catch (err) {
      writeToFile(err.toString());
    }

    try {
      await _clearTmpDir();
    } catch (err) {
      writeToFile(err.toString());
    }
  }

  static Future<void> _writeLogStart() async {
    // LogStart direkt schreiben, damit das File sofort angelegt wird.
    final messageItem = _createMessageQueueItem('START\n-------------------------\n ${AppInfo.appName} (v ${AppInfo.version})\n-------------------------');

    try {
      await _writeToTodayFile([messageItem]);
    } catch (err) {
      if (kDebugMode) {
        print('Failed to write logs!\n\n$err');
      }
    }
  }

  /// liefert die Dateinamen unter logs (ohne die Endung .txt)
  static Future<List<String>> listLogFileNames() async {
    final logs = _logsDir;
    List<String> result = [];
    if (logs == null) return result;
    await logs.list().forEach((element) {
      // result.add(element.path);
      result.add(element.path.split(Platform.pathSeparator).last);
    });
    return result.reversed.toList();
  }

  static Future<List<String>> listTmpFileNames() async {
    final logs = _tmpDir;
    List<String> result = [];
    if (logs == null) return result;
    await logs.list().forEach((element) {
      result.add(element.path.split(Platform.pathSeparator).last);
    });
    return result.reversed.toList();
  }

  static bool logsDirAvailable() {
    return _logsDir != null;
  }

  static void writeToFile(String value, {DateTime? dateTime}) {
    _MsgQueueItem msgQueueItem = _createMessageQueueItem(value, dateTime: dateTime);
    _msgQueue.add(msgQueueItem);
    if (_timerSet) return;
    _timerSet = true;
    Timer(
      const Duration(milliseconds: 1000),
      () async {
        final messages = [..._msgQueue];
        _msgQueue.clear();
        _timerSet = false;
        if (messages.isEmpty) return;
        try {
          await _writeToTodayFile(messages);
        } catch (err) {
          if (kDebugMode) {
            print('Failed to write logs!\n\n$err');
          }
        }
      },
    );
  }

  static _MsgQueueItem _createMessageQueueItem(String value, {DateTime? dateTime}) {
    final logDateTime = dateTime ?? DateTime.now();
    final ms = logDateTime.millisecond.toString().padLeft(3, '0');
    final msgQueueItem = _MsgQueueItem(DateFormat('yyyy-MM-dd').format(logDateTime), '${DateFormat('HH:mm:ss').format(logDateTime)}.$ms', value);
    return msgQueueItem;
  }

  static Future<void> _writeToTodayFile(List<_MsgQueueItem> msgQueueItems) async {
    if (msgQueueItems.isEmpty) return;

    final logsDir = _logsDir;
    if (logsDir == null) {
      if (kDebugMode) {
        for (var msgQueueItem in msgQueueItems) {
          print('[${msgQueueItem.date} ${msgQueueItem.time}] ${msgQueueItem.text}');
        }
      }
      return;
    }

    var soFarDate = msgQueueItems.first.date;
    var todayLog = '$soFarDate.txt';
    _todayLog = todayLog;

    var logFile = File('${logsDir.path}/$todayLog');
    var sink = logFile.openWrite(mode: FileMode.append);

    for (var i = 0; i < msgQueueItems.length; ++i) {
      var msgQueueItem = msgQueueItems[i];

      // check for new date
      if (soFarDate != msgQueueItem.date) {
        await sink.flush();
        await sink.close();

        soFarDate = msgQueueItems.first.date;
        todayLog = '$soFarDate.txt';
        _todayLog = todayLog;

        logFile = File('${logsDir.path}/$todayLog');
        sink = logFile.openWrite(mode: FileMode.append);
      }

      sink.write('[${msgQueueItem.date} ${msgQueueItem.time}] ${msgQueueItem.text}\n');
    }

    await sink.flush();
    await sink.close();
  }

  static Future<String> readLog(String filename, BuildContext context, bool addNLAfterLogLevel) async {
    final logsDir = _logsDir;
    if (logsDir == null) return 'No logs dir set/found!';
    String fn = filename;
    final logFile = File('${logsDir.path}/$fn');

    var logMsgFileNotFound = 'File "$filename" not found!';
    if (!await logFile.exists()) return logMsgFileNotFound;

    final lines = await logFile.readAsLines();
    if (addNLAfterLogLevel) {
      return lines.map((e) => e.replaceFirst(' | ', '\n')).join('\n');
    }
    return lines.join('\n');
  }

  static Future<List<String>> readLogLines(String filename, BuildContext context, bool addNLAfterLogLevel) async {
    final logsDir = _logsDir;
    if (logsDir == null) return ['No logs dir set/found!'];
    String fn = filename;
    final logFile = File('${logsDir.path}/$fn');

    final logMsgFileNotFound = 'File "$filename" not found!';
    if (!await logFile.exists()) return [logMsgFileNotFound];

    final lines = await logFile.readAsLines();

    List<String> result = [];
    String actString = '';

    for (var line in lines) {
      if (line.startsWith('[') && actString.isNotEmpty) {
        result.add(actString);
        actString = '';
      }

      String l = line;
      if (actString.isEmpty && addNLAfterLogLevel) {
        l = l.replaceFirst(' | ', '\n');
        l = l.replaceFirst(') ', ')\n');
      }

      if (actString.isNotEmpty) actString += '\n';
      actString += l;
    }

    if (actString.isNotEmpty) {
      result.add(actString);
    }

    return result;
  }

  static String getFullLogPath(String filename) {
    final logsDir = _logsDir;
    if (logsDir == null) return 'No logs dir set/found!';
    String fn = filename;
    return '${logsDir.path}/$fn';
  }

  static Future<void> deleteLog(String filename) async {
    final logsDir = _logsDir;
    if (logsDir == null) return;
    await File('${logsDir.path}/$filename').delete();

    // Aktuelles File entfernen? Dann neues File anlegen...
    if (filename == _todayLog) {
      _writeLogStart();
    }
  }

  static Future<void> deleteAllLogs() async {
    final logsDir = _logsDir;
    if (logsDir == null) return;
    _logsDir = null;
    await logsDir.delete(recursive: true);
    await init();
  }

  static Future<void> _clearTmpDir() async {
    final tmpDir = _tmpDir;
    if (tmpDir == null) return;
    tmpDir.list(recursive: true).listen((file) async {
      if (file is File) {
        if (kDebugMode) {
          print('del tmp file $file');
        }
        try {
          await file.delete();
        } catch (err) {
          if (kDebugMode) {
            print('Failed to del tmp file $file');
          }
        }
      }
    });
  }

  static Future<void> _clearOldLogs() async {
    final logsDir = _logsDir;
    if (logsDir == null) return;

    final List<String> whiteList = [];

    var date = DateTime.now();
    for (var i = 0; i < _keepLogsForDays; ++i) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final logName = '$formattedDate.txt';
      final logFile = File('${logsDir.path}/$logName');
      whiteList.add(logFile.path);
      // print(logFile.path);
      date = date.add(const Duration(days: -1));
    }

    logsDir.list(recursive: false).listen((file) async {
      if (file is File) {
        if (!whiteList.contains(file.path)) {
          if (kDebugMode) {
            print('del old log file $file');
          }
          try {
            await file.delete();
          } catch (err) {
            if (kDebugMode) {
              print('Failed to del tmp file $file');
            }
          }
        }
      }
    });
  }

  static Future<String> zipAllLogs() async {
    final tmpDir = _tmpDir;
    if (tmpDir == null) throw 'No tmp dir available!';
    final logsDir = _logsDir;
    if (logsDir == null) throw 'No log dir found!';
    var zipFile = File('${tmpDir.path}/logs_${DateFormat('yyyy-MM-dd_HH_mm_ss').format(DateTime.now())}.zip');
    await ZipFile.createFromDirectory(sourceDir: logsDir, zipFile: zipFile, recurseSubDirs: true);
    return zipFile.path;
  }
}

class _MsgQueueItem {
  _MsgQueueItem(this.date, this.time, this.text);

  final String date;
  final String time;
  final String text;
}
