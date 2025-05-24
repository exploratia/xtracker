import 'package:flutter/material.dart';

import '../../model/navigation/navigation.dart';
import '../../util/navigation/hide_navigation_labels.dart';
import 'hide_bottom_navigation_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return ValueListenableBuilder(
      valueListenable: HideNavigationLabels.visible,
      builder: (BuildContext ctx0, navLabelsVisible, _) => ValueListenableBuilder(
        valueListenable: HideBottomNavigationBar.visible,
        builder: (BuildContext ctx1, isVisible, _) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isVisible ? MediaQuery.of(context).padding.bottom + (40 + 16) : 0,
          child: OverflowBox(
            maxHeight: double.infinity,
            minHeight: 0,
            alignment: AlignmentDirectional.topCenter,
            child: ValueListenableBuilder(
              valueListenable: Navigation.currentMainNavigationIdx,
              builder: (BuildContext ctx2, currentIdx, _) => Container(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: themeData.shadowColor,
                      blurRadius: 8,
                    ),
                  ],
                  // border: Border(
                  //     top: BorderSide(
                  //         color: themeData.scaffoldBackgroundColor, width: 1.0)),
                ),
                child: BottomNavigationBar(
                  showUnselectedLabels: navLabelsVisible,
                  showSelectedLabels: navLabelsVisible,
                  backgroundColor: themeData.cardTheme.color,
                  items: _buildNavItems(ctx2),
                  currentIndex: currentIdx,
                  type: BottomNavigationBarType.fixed,
                  onTap: (selectedIdx) => Navigation.setCurrentMainNavigationRouteIdx(selectedIdx, ctx2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems(BuildContext context) {
    List<BottomNavigationBarItem> result = [];

    for (var navItem in Navigation.mainNavigationItems) {
      result.add(BottomNavigationBarItem(
        icon: navItem.icon,
        label: navItem.titleBuilder(),
      ));
    }

    return result;
  }
}
