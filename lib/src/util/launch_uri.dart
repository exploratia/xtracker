import 'package:url_launcher/url_launcher.dart';

import 'globals.dart';
import 'logging/flutter_simple_logging.dart';

class LaunchUri {
  static Future<void> launchUri(Uri uri) async {
    try {
      if (!await launchUrl(uri)) {
        SimpleLogging.w('Could not launch $uri');
      }
    } catch (err) {
      SimpleLogging.w('Could not launch $uri', error: err);
    }
  }

  static Future<void> launchUriExploratia() async {
    return launchUri(Globals.urlExploratia);
  }
}
