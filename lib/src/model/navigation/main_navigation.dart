import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../screens/administration/administration_screen.dart';
import '../../screens/home_screen.dart';
import '../../util/text_utils.dart';
import 'main_navigation_item.dart';

class MainNavigation {
  static final ValueNotifier<int> currentIdx = ValueNotifier<int>(0);

  static void setCurrentIdx(int value) {
    if (currentIdx.value != value) {
      currentIdx.value = value;
    }
  }

  static final List<MainNavigationItem> mainNavigationItems =
      _buildMainNavItems();

  static List<MainNavigationItem> _buildMainNavItems() {
    List<MainNavigationItem> navItems = [];
    navItems.add(HomeScreen.mainNavigationItem);
    navItems.add(AdministrationScreen.mainNavigationItem);
    return navItems;
  }

  static double maxTextWidth = 304; // initial default drawer width

  /// determines the maxTextWidth for all navigation items to know the required drawer width.
  /// Has to be called after language changed.
  static void determineMaxTextWidth(
      {required BuildContext context, TextStyle? textStyle}) {
    final t = AppLocalizations.of(context)!;
    double maxW = 0;
    for (var navItem in mainNavigationItems) {
      var text = navItem.titleBuilder(t);
      var width = TextUtils.determineTextSize(text, context, textStyle).width;
      maxW = max(maxW, width);
    }
    maxTextWidth = maxW;
  }
}
