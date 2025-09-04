import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/navigation/navigation.dart';
import '../../../util/theme_utils.dart';

class AppNavigationRail extends StatefulWidget {
  const AppNavigationRail({super.key});

  @override
  State<AppNavigationRail> createState() => _AppNavigationRailState();
}

class _AppNavigationRailState extends State<AppNavigationRail> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx1, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          // ohne LayoutBuilder:  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height,
          child: IntrinsicHeight(
            child: ValueListenableBuilder(
              valueListenable: Navigation.currentMainNavigationIdx,
              builder: (BuildContext ctx2, currentIdx, _) => NavigationRail(
                selectedIndex: currentIdx + 1,
                destinations: _buildDestinations(ctx2),
                extended: Navigation.navRailExpanded,
                minExtendedWidth: Navigation.getDrawerTextWidth(context) + 120,
                onDestinationSelected: (int index) {
                  if (index == 0) {
                    Navigation.navRailExpanded = !Navigation.navRailExpanded;
                  } else {
                    Navigation.setCurrentMainNavigationRouteIdx(index - 1, ctx2);
                  }
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<NavigationRailDestination> _buildDestinations(BuildContext context) {
    List<NavigationRailDestination> result = [];

    // special expand item
    result.add(NavigationRailDestination(
      icon: Tooltip(
        message: Navigation.navRailExpanded ? LocaleKeys.commons_nav_hideMenu.tr() : LocaleKeys.commons_nav_openMenu.tr(),
        child: Icon(
          Navigation.navRailExpanded ? Icons.arrow_left : Icons.arrow_right,
          size: ThemeUtils.iconSizeScaled,
        ),
      ),
      label: const SizedBox(width: 0, height: 0),
    ));

    for (var navItem in Navigation.mainNavigationItems) {
      result.add(NavigationRailDestination(
        icon: Tooltip(message: navItem.tooltipBuilder(), child: navItem.icon()),
        label: Text(navItem.titleBuilder()),
      ));
    }

    return result;
  }
}
