import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../util/theme_utils.dart';
import '../../controls/card/expandable_settings_card.dart';
import '../../controls/layout/scroll_footer.dart';
import '../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../controls/layout/wallpaper.dart';
import '../../controls/navigation/hide_bottom_navigation_bar.dart';
import '../../controls/text/overflow_text.dart';
import './settings_controller.dart';
import 'device_storage_view.dart';
import 'general_settings_view.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Wallpaper(
      showWallpaper: settingsController.showWallpaper,
      child: SingleChildScrollViewWithScrollbar(
        useScreenPadding: true,
        scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
        child: Column(
          spacing: ThemeUtils.cardPadding,
          children: [
            ExpandableSettingsCard(
                title: OverflowText(LocaleKeys.settings_general_title.tr(), style: Theme.of(context).textTheme.titleLarge),
                content: GeneralSettingsView(controller: settingsController)),
            ExpandableSettingsCard(
                title: OverflowText(LocaleKeys.settings_deviceStorage_title.tr(), style: Theme.of(context).textTheme.titleLarge),
                content: DeviceStorageView(
                  controller: settingsController,
                )),
            const ScrollFooter(),
          ],
        ),
      ),
    );
  }
}
