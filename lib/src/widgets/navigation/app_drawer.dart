import 'package:flutter/material.dart';

import '../../model/navigation/navigation.dart';
import '../../util/navigation/hide_navigation_labels.dart';
import '../../util/navigation/navigation_utils.dart';
import '../layout/single_child_scroll_view_with_scrollbar.dart';
import 'app_drawer_header.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HideNavigationLabels.visible,
      builder: (BuildContext ctx0, navLabelsVisible, _) => Drawer(
          // + icon and padding
          width: (navLabelsVisible ? Navigation.getDrawerTextWidth(context) : 0) + 130,
          child: Column(
            children: [
              const AppDrawerHeader(),
              // Divider(),
              Expanded(
                child: SingleChildScrollViewWithScrollbar(
                  child: ValueListenableBuilder(
                    valueListenable: Navigation.currentMainNavigationIdx,
                    builder: (BuildContext ctx, currentIdx, _) => _buildNavItems(ctx, currentIdx, navLabelsVisible),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildNavItems(BuildContext context, int currentIdx, bool navLabelsVisible) {
    List<Widget> result = [];

    int actIdx = -1;
    for (var navItem in Navigation.mainNavigationItems) {
      int itemIdx = ++actIdx;
      result.add(ListTile(
        selected: actIdx == currentIdx,
        leading: navLabelsVisible ? navItem.icon : null,
        title: navLabelsVisible ? Text(navItem.titleBuilder()) : navItem.icon,
        onTap: () {
          NavigationUtils.closeDrawerIfOpen(context);
          Navigation.setCurrentMainNavigationRouteIdx(itemIdx, context);
        },
      ));
    }

    return Column(children: result);
  }
}
