import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';

import 'launch_uri.dart';
import 'logging/flutter_simple_logging.dart';

class AppIconQuickActions {
  static const _actionOpenExploratia = 'open_exploratia';
  static const _quickActions = QuickActions();

  static Future<void> init() async {
    // QuickActions are only available on Android and iOS.
    if (kIsWeb) {
      return;
    }
    final platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
      return;
    }

    try {
      await _quickActions.initialize((String actionType) {
        if (actionType == _actionOpenExploratia) {
          LaunchUri.launchUriExploratia();
        }
      });

      await _quickActions.setShortcutItems(const <ShortcutItem>[
        ShortcutItem(
          type: _actionOpenExploratia,
          localizedTitle: 'exploratia.de',
        ),
      ]);
    } catch (err) {
      SimpleLogging.w('Could not initialize app icon quick actions', error: err);
    }
  }
}
