import 'package:flutter/material.dart';

import '../../../model/navigation/navigation.dart';
import '../../../util/chart/chart_utils.dart';
import '../../../util/color_utils.dart';
import '../../../util/navigation/hide_navigation_labels.dart';
import '../../../util/theme_utils.dart';
import 'hide_bottom_navigation_bar.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    const animationDuration = Duration(milliseconds: ThemeUtils.animationDuration);
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: HideNavigationLabels.visible,
        builder: (BuildContext ctx0, navLabelsVisible, _) => ValueListenableBuilder(
          valueListenable: HideBottomNavigationBar.visible,
          builder: (BuildContext ctx1, isVisible, _) {
            return AnimatedContainer(
              duration: animationDuration,
              height: isVisible ? kBottomNavigationBarHeight : 0,
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                duration: animationDuration,
                opacity: isVisible ? 1.0 : 0.0,
                child: AnimatedSlide(
                  duration: animationDuration,
                  offset: isVisible ? const Offset(0, 0) : const Offset(0, 1),
                  child: OverflowBox(
                    maxHeight: double.infinity,
                    minHeight: 0,
                    alignment: AlignmentDirectional.topCenter,
                    child: ValueListenableBuilder(
                      valueListenable: Navigation.currentMainNavigationIdx,
                      builder: (BuildContext ctx2, currentIdx, _) => Container(
                        decoration: buildBottomNavigationBarDecoration(ctx2),
                        child: BottomNavigationBar(
                          // set background to transparent (override the theme data) to see the parent background
                          backgroundColor: Colors.transparent,
                          showUnselectedLabels: navLabelsVisible,
                          showSelectedLabels: navLabelsVisible,
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
          },
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems(BuildContext context) {
    List<BottomNavigationBarItem> result = [];

    for (var navItem in Navigation.mainNavigationItems) {
      result.add(BottomNavigationBarItem(
        icon: navItem.icon(),
        label: navItem.titleBuilder(),
        tooltip: navItem.tooltipBuilder(),
      ));
    }

    return result;
  }

  static BoxDecoration buildBottomNavigationBarDecoration(BuildContext context) {
    final themeData = Theme.of(context);
    Color baseColor = themeData.bottomNavigationBarTheme.backgroundColor ?? Colors.grey;
    return BoxDecoration(
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: themeData.shadowColor,
          blurRadius: 8,
        ),
      ],
      gradient: ChartUtils.createTopToBottomGradient([baseColor, ColorUtils.darken(baseColor, 40)]),
    );
  }
}
