import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/changelog/change_log_entry.dart';
import '../../model/navigation/navigation_item.dart';
import '../../util/theme_utils.dart';
import '../../widgets/administration/settings/settings_controller.dart';
import '../../widgets/changelog/change_log_entries_view.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/card/settings_card.dart';
import '../../widgets/controls/layout/scroll_footer.dart';
import '../../widgets/controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../widgets/controls/navigation/hide_bottom_navigation_bar.dart';
import '../../widgets/controls/responsive/screen_builder.dart';

/// Shows the full release history from administration.
class ChangeLogScreen extends StatelessWidget {
  /// Navigation metadata for the release history route.
  static NavigationItem navItem = NavigationItem(
    iconData: Icons.new_releases_outlined,
    routeName: '/change_log_screen',
    titleBuilder: () => LocaleKeys.changeLog_title.tr(),
  );

  const ChangeLogScreen({super.key, required this.settingsController});

  /// User preferences for the standard screen layout.
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      showWallpaper: settingsController.showWallpaper,
      appBarBuilder: (context) => GradientAppBar.build(
        context,
        addLeadingBackBtn: true,
        title: Text(navItem.titleBuilder()),
      ),
      bodyBuilder: (context) => SingleChildScrollViewWithScrollbar(
        useScreenPadding: true,
        scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
        child: Column(
          spacing: ThemeUtils.cardPadding,
          mainAxisSize: MainAxisSize.min,
          children: [
            SettingsCard.singleEntry(
              showDivider: false,
              content: const ChangeLogEntriesView(entries: ChangeLog.entries),
            ),
            const ScrollFooter(),
          ],
        ),
      ),
    );
  }
}
