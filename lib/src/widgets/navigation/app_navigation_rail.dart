import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/navigation/main_navigation.dart';

class AppNavigationRail extends StatefulWidget {
  const AppNavigationRail({super.key});

  @override
  State<AppNavigationRail> createState() => _AppNavigationRailState();
}

class _AppNavigationRailState extends State<AppNavigationRail> {
  bool _extended = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx1, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          // ohne LayoutBuilder:  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height,
          child: IntrinsicHeight(
            child: ValueListenableBuilder(
              valueListenable: MainNavigation.currentIdx,
              builder: (BuildContext ctx2, currentIdx, _) => NavigationRail(
                selectedIndex: currentIdx + 1,
                destinations: _buildDestinations(ctx2),
                extended: _extended,
                onDestinationSelected: (int index) {
                  setState(() {
                    if (index == 0) {
                      _extended = !_extended;
                    } else {
                      MainNavigation.setCurrentIdx(index - 1, ctx2);
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<NavigationRailDestination> _buildDestinations(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    List<NavigationRailDestination> result = [];

    // special expand item
    result.add(NavigationRailDestination(
      icon: Icon(_extended ? Icons.arrow_left : Icons.arrow_right),
      label: const SizedBox(width: 0, height: 0),
    ));

    for (var navItem in MainNavigation.mainNavigationItems) {
      result.add(NavigationRailDestination(
        icon: navItem.icon,
        label: Text(navItem.titleBuilder(t)),
      ));
    }

    return result;
  }
}
