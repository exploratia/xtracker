import 'package:flutter/material.dart';

import '../../util/globals.dart';
import '../../util/media_query_utils.dart';

class ScreenBuilder extends StatelessWidget {
  final PreferredSizeWidget Function(BuildContext context)? appBarBuilder;
  final Widget Function(BuildContext context) bodyBuilder;

  /// Builder-Funktionen, damit nur erzeugt wird, falls auch benoetigt.
  final Widget Function(BuildContext context)? drawerBuilder;
  final Widget Function(BuildContext context)? bottomNavigationBarBuilder;
  final Widget Function(BuildContext context)? navigationRailBuilder;
  final Widget Function(BuildContext context)? floatingActionButtonBuilder;

  const ScreenBuilder(
      {super.key,
      required this.bodyBuilder,
      this.appBarBuilder,
      this.floatingActionButtonBuilder,
      this.drawerBuilder,
      this.bottomNavigationBarBuilder,
      this.navigationRailBuilder});

  @override
  Widget build(BuildContext context) {
    final mediaQueryInfo = MediaQueryUtils(MediaQuery.of(context));
    final buildDrawer = (/*!mediaQueryInfo.isTablet &&*/
        mediaQueryInfo.isLandscape && drawerBuilder != null);
    final buildBottomNavigationBar =
        (mediaQueryInfo.isPortrait && bottomNavigationBarBuilder != null);
    final buildNavigationRail =
        ((mediaQueryInfo.isLandscape || mediaQueryInfo.isTablet) &&
            navigationRailBuilder != null);
    return Scaffold(
      key: Globals.scaffoldKey,
      appBar: appBarBuilder != null ? appBarBuilder!(context) : null,
      drawer: buildDrawer ? SafeArea(child: drawerBuilder!(context)) : null,
      bottomNavigationBar: buildBottomNavigationBar
          ? bottomNavigationBarBuilder!(context)
          : null,
      body: SafeArea(
          child: Row(
        children: [
          if (buildNavigationRail) navigationRailBuilder!(context),
          if (buildNavigationRail)
            const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: bodyBuilder(context)),
        ],
      )),
      floatingActionButton: floatingActionButtonBuilder != null
          ? floatingActionButtonBuilder!(context)
          : null,
    );
  }
}
