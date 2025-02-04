import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NavigationUtils {
  static RouteSettings? getActRouteSettings(BuildContext ctx) {
    return ModalRoute.of(ctx)?.settings;
  }

  static bool closeDrawerIfOpen(BuildContext context) {
    var scaffoldState = Scaffold.maybeOf(context);
    return closeDrawer(scaffoldState);
  }

  static bool closeDrawer(ScaffoldState? scaffoldState) {
    if (scaffoldState?.isDrawerOpen ?? false) {
      scaffoldState?.closeDrawer();
      return true;
    }
    return false;
  }

  /// only for debug - destroys app
  static void printNavStack(BuildContext context) {
    Navigator.of(context).popUntil((route) {
      if (kDebugMode) {
        print('Debug navigator stack: ${route.settings.name}');
      }
      return false;
    });
  }
}
