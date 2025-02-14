import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/navigation/main_navigation_item.dart';
import '../model/series/series_def.dart';
import '../providers/series_provider.dart';
import '../util/globals.dart';
import '../widgets/layout/gradient_app_bar.dart';
import '../widgets/navigation/hide_bottom_navigation_bar.dart';
import '../widgets/responsive/screen_builder.dart';
import '../widgets/series/management/series_management_view.dart';
import '../widgets/series/series_view.dart';

class HomeScreen extends StatelessWidget {
  static MainNavigationItem navItem = MainNavigationItem(
    icon: const Icon(Icons.home_outlined),
    routeName: '/',
    titleBuilder: (t) => t.homeTitle,
  );

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    // Reorder possible?
    Future Function()? showReorderDlg;

    if (context.watch<SeriesProvider>().series.isNotEmpty) {
      showReorderDlg = () async {
        await showDialog<SeriesDef>(
            context: context,
            builder: (context) {
              return Dialog.fullscreen(
                backgroundColor: themeData.scaffoldBackgroundColor,
                child: const HideBottomNavigationBar(child: SeriesManagementView()),
              );
            });
      };
    } else {
      showReorderDlg = null;
    }

    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) {
        return GradientAppBar.build(context,
            title: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Image.asset(
                    Globals.assetImgAppLogoWhite,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    /*SeriesDef? s=*/ await SeriesDef.addNewSeries(context);
                  },
                  icon: const Icon(Icons.add_chart_outlined)),
              IconButton(onPressed: showReorderDlg, icon: const Icon(Icons.edit_outlined)),
            ]);
      },
      bodyBuilder: (context) => const SeriesView(),
    );
  }
}
