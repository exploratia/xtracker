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
}
