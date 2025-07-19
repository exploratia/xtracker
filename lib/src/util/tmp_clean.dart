import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'logging/flutter_simple_logging.dart';

class TmpClean {
  static Future<void> clearTmpDirectory() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        final files = tempDir.listSync(recursive: true);
        for (final file in files) {
          try {
            if (file is File) {
              await file.delete();
            } else if (file is Directory) {
              await file.delete(recursive: true);
            }
          } catch (e) {
            if (e is! PathNotFoundException) {
              if (kDebugMode) {
                print('Failed to delete ${file.path}: $e');
              }
              SimpleLogging.w('Failed to delete ${file.path}.', error: e);
            }
          }
        }
      }
      if (kDebugMode) {
        print("Temp dir cleared.");
      }
      SimpleLogging.i('Temp dir cleared.');
    } catch (e) {
      if (kDebugMode) {
        print("Failed to read temp dir: $e");
      }
      SimpleLogging.w('Failed to read temp dir.', error: e);
    }
  }
}
