import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../screens/administration/info_screen.dart';
import '../../screens/administration/logs_screen.dart';
import '../../screens/administration/settings_screen.dart';
import '../../util/about_dlg.dart';
import '../../util/navigation/hide_bottom_navigation_bar.dart';
import '../card/settings_card.dart';
import '../layout/single_child_scroll_view_with_scrollbar.dart';

class AdministrationView extends StatelessWidget {
  const AdministrationView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    final links = [
      SettingsScreen.navItem,
      LogsScreen.navItem,
      InfoScreen.navItem
    ].map((navItem) => {
          'ico': navItem.icon,
          'title': navItem.titleBuilder(t),
          'routeName': navItem.routeName,
        });

    return SingleChildScrollViewWithScrollbar(
      scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
      child: SettingsCard(
        spacing: 10,
        showDivider: false,
        children: [
          ...links.map((lnk) => ListTile(
                leading: lnk['ico'] as Widget,
                title: Text(lnk['title'] as String),
                trailing: Icon(
                  Icons.navigate_next,
                  color: themeData.colorScheme.primary,
                ),
                onTap: () => Navigator.restorablePushNamed(
                    context, lnk['routeName'] as String),
              )),
          OutlinedButton.icon(
            onPressed: () => AboutDlg.showAboutDlg(context),
            icon: const Icon(Icons.info_outline),
            label: const Text("Version"),
          ),
        ],
      ),
    );
  }
}
