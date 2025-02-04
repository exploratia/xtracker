import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/navigation/navigation.dart';
import '../../util/navigation/navigation_utils.dart';
import '../layout/single_child_scroll_view_with_scrollbar.dart';
import 'app_drawer_header.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        // + icon and padding
        width: Navigation.getDrawerTextWidth(context) + 130,
        child: Column(
          children: [
            const AppDrawerHeader(),
            // Divider(),
            Expanded(
              child: SingleChildScrollViewWithScrollbar(
                child: ValueListenableBuilder(
                  valueListenable: Navigation.currentMainNavigationIdx,
                  builder: (BuildContext ctx, currentIdx, _) =>
                      _buildNavItems(ctx, currentIdx),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildNavItems(BuildContext context, int currentIdx) {
    final t = AppLocalizations.of(context)!;
    List<Widget> result = [];

    int actIdx = -1;
    for (var navItem in Navigation.mainNavigationItems) {
      int itemIdx = ++actIdx;
      result.add(ListTile(
        selected: actIdx == currentIdx,
        leading: navItem.icon,
        title: Text(navItem.titleBuilder(t)),
        onTap: () {
          NavigationUtils.closeDrawerIfOpen(context);
          Navigation.setCurrentMainNavigationRouteIdx(itemIdx, context);
        },
      ));
    }

    return Column(children: result);
  }
}
