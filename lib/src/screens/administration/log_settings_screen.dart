import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/navigation_item.dart';
import '../../widgets/administration/logging/log_settings_view.dart';
import '../../widgets/controls/layout/gradient_app_bar.dart';
import '../../widgets/controls/responsive/screen_builder.dart';

class LogSettingsScreen extends StatelessWidget {
  static NavigationItem navItem = NavigationItem(
    icon: const Icon(Icons.settings_outlined),
    routeName: '/log_settings_screen',
    titleBuilder: () => LocaleKeys.logSettings_title.tr(),
  );

  const LogSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(context, addLeadingBackBtn: true, title: Text(navItem.titleBuilder())),
      bodyBuilder: (context) => const LogSettingsView(),
    );
  }
}
