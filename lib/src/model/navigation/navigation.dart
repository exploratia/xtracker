import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/text_utils.dart';
import 'main_navigation_item.dart';

class Navigation {
  static final ValueNotifier<int> currentMainNavigationIdx =
      ValueNotifier<int>(0);

  static void setCurrentMainNavigationRouteIdx(
      int value, BuildContext context) {
    if (value < 0 || currentMainNavigationIdx.value == value) return;

    currentMainNavigationIdx.value = value;
    var currentItem = mainNavigationItems[value];
    Navigator.pushReplacementNamed(context, currentItem.routeName);
  }

  static void setCurrentMainNavigationRoute(
      String routeName, BuildContext context) {
    setCurrentMainNavigationRouteIdx(_indexOfRoute(routeName), context);
  }

  static bool containsMainNavigationRoute(String routeName) {
    return _indexOfRoute(routeName) >= 0;
  }

  static int _indexOfRoute(String routeName) {
    return mainNavigationItems
        .indexWhere((navItem) => navItem.routeName == routeName);
  }

  /// [MainNavigationItem] registers itself in constructor
  static final List<MainNavigationItem> mainNavigationItems = [];

  static void registerMainNavigationItem(
      MainNavigationItem mainNavigationItem) {
    mainNavigationItems.add(mainNavigationItem);
    _maxTextWidth = -1;
  }

  /// initial default drawer width
  static double _maxTextWidth = -1;

  static double getDrawerTextWidth(BuildContext context,
      {TextStyle? textStyle}) {
    if (_maxTextWidth < 0) {
      _determineMaxTextWidth(context: context, textStyle: textStyle);
    }
    return _maxTextWidth;
  }

  /// force recalculation on next usage
  static void resetMaxTextWidth() {
    _maxTextWidth = -1;
  }

  /// determines the maxTextWidth for all main navigation items to know the required drawer width.
  /// Has to be called after language changed.
  static void _determineMaxTextWidth(
      {required BuildContext context, TextStyle? textStyle}) {
    final t = AppLocalizations.of(context)!;
    double maxW = -1;
    for (var navItem in mainNavigationItems) {
      var text = navItem.titleBuilder(t);
      var width = TextUtils.determineTextSize(text, context, textStyle).width;
      maxW = max(maxW, width);
    }
    if (kDebugMode) {
      print('Determined main nav text width: $maxW');
    }
    if (maxW < 0) maxW = 304;
    _maxTextWidth = maxW;
  }
}
