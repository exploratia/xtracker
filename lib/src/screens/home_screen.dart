import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.gen.dart';
import '../../generated/locale_keys.g.dart';
import '../model/navigation/main_navigation_item.dart';
import '../model/series/series_def.dart';
import '../widgets/layout/gradient_app_bar.dart';
import '../widgets/navigation/hide_bottom_navigation_bar.dart';
import '../widgets/responsive/screen_builder.dart';
import '../widgets/series/management/series_management_view.dart';
import '../widgets/series/series_view.dart';

class HomeScreen extends StatelessWidget {
  static MainNavigationItem navItem = MainNavigationItem(
    icon: const Icon(Icons.home_outlined),
    routeName: '/',
    titleBuilder: () => LocaleKeys.home_title.tr(),
  );

  const HomeScreen({super.key});

  void _showSeriesManagement(BuildContext context) async {
    final themeData = Theme.of(context);
    await showDialog<SeriesDef>(
        context: context,
        builder: (context) {
          return Dialog.fullscreen(
            backgroundColor: themeData.scaffoldBackgroundColor,
            child: const HideBottomNavigationBar(child: SeriesManagementView()),
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
                  onPressed: () async {
                    /*SeriesDef? s=*/ await SeriesDef.addNewSeries(context);
                  },
                  icon: const Icon(Icons.add_chart_outlined)),
              IconButton(onPressed: () => _showSeriesManagement(context), icon: const Icon(Icons.edit_outlined)),
            ]);
      },
      bodyBuilder: (context) => const SeriesView(),
    );
  }
}
