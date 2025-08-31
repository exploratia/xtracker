import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.gen.dart';
import '../../generated/locale_keys.g.dart';
import '../model/navigation/main_navigation_item.dart';
import '../model/series/series_def.dart';
import '../widgets/administration/settings/settings_controller.dart';
import '../widgets/controls/appbar/gradient_app_bar.dart';
import '../widgets/controls/navigation/hide_bottom_navigation_bar.dart';
import '../widgets/controls/responsive/screen_builder.dart';
import '../widgets/series/management/series_management_view.dart';
import '../widgets/series/series_view.dart';

class HomeScreen extends StatelessWidget {
  static MainNavigationItem navItem = MainNavigationItem(
    icon: const Icon(Icons.home_outlined),
    routeName: '/',
    titleBuilder: () => LocaleKeys.seriesDashboard_nav_title.tr(),
    tooltipBuilder: () => LocaleKeys.seriesDashboard_nav_tooltip.tr(),
  );

  final SettingsController settingsController;

  const HomeScreen({super.key, required this.settingsController});

  void _showSeriesManagement(BuildContext context) async {
    final themeData = Theme.of(context);
    await showDialog<SeriesDef>(
        context: context,
        builder: (context) {
          return Dialog.fullscreen(
            backgroundColor: themeData.scaffoldBackgroundColor,
            child: HideBottomNavigationBar(
              child: SeriesManagementView(settingsController: settingsController),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) {
        return GradientAppBar.build(context,
            title: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Assets.images.logos.appLogoWhite.image(fit: BoxFit.cover),
                ),
              ],
            ),
            actions: [
              IconButton(
                  tooltip: LocaleKeys.seriesDashboard_action_addSeries_tooltip.tr(),
                  onPressed: () async {
                    /*SeriesDef? s=*/ await SeriesDef.addNewSeries(context);
                  },
                  icon: const Icon(Icons.add_chart_outlined)),
              IconButton(
                tooltip: LocaleKeys.seriesDashboard_action_manageSeries_tooltip.tr(),
                onPressed: () => _showSeriesManagement(context),
                icon: const Icon(Icons.edit_outlined),
              ),
            ]);
      },
      bodyBuilder: (context) => SeriesView(
        settingsController: settingsController,
      ),
    );
  }
}
