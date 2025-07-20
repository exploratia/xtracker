import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/stack/stack_utils.dart';

void main() {
  group('Stack Utils', () {
    test('should determine file and line from stack lines', () {
      StackUtils.init("flutter_test");

      // android emulator
      String stackLine = "package:flutter_test/src/widgets/administration/logging/log_settings_view.dart:58:41";
      var fileLine = StackUtils.determineFileLineAndStack(stackLine);
      expect(fileLine.fileName, "log_settings_view.dart");
      expect(fileLine.lineNo, "58");

      // web
      stackLine = "package:flutter_test/src/widgets/administration/logging/log_settings_view.dart 58:41";
      fileLine = StackUtils.determineFileLineAndStack(stackLine);
      expect(fileLine.fileName, "log_settings_view.dart");
      expect(fileLine.lineNo, "58");

      // real device
      stackLine = "package:flutter_test/src/widgets/administration/logging/log_settings_view.dart:58";
      fileLine = StackUtils.determineFileLineAndStack(stackLine);
      expect(fileLine.fileName, "log_settings_view.dart");
      expect(fileLine.lineNo, "58");
    });
  });
}
