import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/navigation/main_navigation.dart';
import '../../util/navigation/hide_bottom_navigation_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: HideBottomNavigationBar.visible,
      builder: (BuildContext ctx1, isVisible, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isVisible ? 80 : 0,
        child: OverflowBox(
          maxHeight: 80,
          minHeight: 0,
          alignment: AlignmentDirectional.topCenter,
          child: SafeArea(
            child: ValueListenableBuilder(
              valueListenable: MainNavigation.currentIdx,
              builder: (BuildContext ctx2, currentIdx, _) => Container(
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: themeData.colorScheme.secondary, width: 1.0)),
                ),
                child: BottomNavigationBar(
                  backgroundColor: themeData.scaffoldBackgroundColor,
                  items: _buildNavItems(ctx2),
                  currentIndex: currentIdx,
                  type: BottomNavigationBarType.fixed,
                  onTap: (selectedIdx) =>
                      MainNavigation.setCurrentIdx(selectedIdx, ctx2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    List<BottomNavigationBarItem> result = [];

    for (var navItem in MainNavigation.mainNavigationItems) {
      result.add(BottomNavigationBarItem(
        icon: navItem.icon,
        label: navItem.titleBuilder(t),
      ));
    }

    return result;
  }
}
