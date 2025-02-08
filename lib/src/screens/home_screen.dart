import 'package:flutter/material.dart';

import '../model/navigation/main_navigation_item.dart';
import '../model/series/series_def.dart';
import '../util/globals.dart';
import '../widgets/layout/gradient_app_bar.dart';
import '../widgets/responsive/screen_builder.dart';
import '../widgets/series/home_view.dart';

class HomeScreen extends StatelessWidget {
  static MainNavigationItem navItem = MainNavigationItem(
    icon: const Icon(Icons.home_outlined),
    routeName: '/',
    titleBuilder: (t) => t.homeTitle,
  );

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder.withStandardNavBuilders(
      navItem: navItem,
      appBarBuilder: (context) => GradientAppBar.build(context,
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
                  SeriesDef? seriesDef = await SeriesDef.addNewSeries(context);
                  print(seriesDef); // TODO handle
                },
                icon: const Icon(Icons.add_chart_outlined)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
          ]),
      bodyBuilder: (context) => const HomeView(),
    );
  }
}
