import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static String _appName = 'Not initialized';
  static String _packageName = 'Not initialized';
  static String _projectName = 'Not initialized';
  static String _version = '-1,-1,-1';
  static String _buildNumber = '-1';

  static Future<void> init() async {
    // prevent multi init
    if (_buildNumber != '-1') return;

    // Ueber den Stack den project name ermitteln
    final stackMain = StackTrace.current
        .toString()
        .split('\n')
        .where((line) {
          return line.contains('main.dart') && line.contains('package:');
        })
        .toList()
        .firstOrNull;

    if (stackMain != null) {
      final idxColon = stackMain.indexOf(':');
      if (idxColon > 0) {
        final idxSlash = stackMain.indexOf('/', idxColon);
        if (idxSlash > 0) {
          _projectName = stackMain.substring(idxColon + 1, idxSlash);
        }
      }
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _appName = packageInfo.appName;
    _packageName = packageInfo.packageName;
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
  }

  static String get appName => _appName;

  /// e.g. de.exploratia.abc
  static String get packageName => _packageName;

  /// project name from pubspec.yaml = package name for classes / imports
  static String get projectName => _projectName;

  static String get version => _version;

  static String get buildNumber => _buildNumber;
}
