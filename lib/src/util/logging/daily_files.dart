// Plattformabhängige Implementierung exportieren:
// - Flutter (mobile/desktop): daily_files_io.dart (nutzt dart:io)
// - Web: daily_files_web.dart (konsolenbasiert, keine Files)
export 'daily_files_io.dart' if (dart.library.html) 'daily_files_web.dart';