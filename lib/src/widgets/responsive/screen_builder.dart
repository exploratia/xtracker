import 'package:flutter/material.dart';

import '../../util/media_query_utils.dart';
import '../navigation/double_back_to_close.dart';
import '../navigation/pop_back_to_home.dart';

class ScreenBuilder extends StatelessWidget {
  final PreferredSizeWidget Function(BuildContext context)? appBarBuilder;
  final Widget Function(BuildContext context) bodyBuilder;

  /// Builder-Funktionen, damit nur erzeugt wird, falls auch benoetigt.
  final Widget Function(BuildContext context)? drawerBuilder;
  final Widget Function(BuildContext context)? bottomNavigationBarBuilder;
  final Widget Function(BuildContext context)? navigationRailBuilder;
  final Widget Function(BuildContext context)? floatingActionButtonBuilder;

  /// HomeScreen ? for double back to close
  final bool isHome;

  const ScreenBuilder({
    super.key,
    required this.bodyBuilder,
    this.appBarBuilder,
    this.floatingActionButtonBuilder,
    this.drawerBuilder,
    this.bottomNavigationBarBuilder,
    this.navigationRailBuilder,
    this.isHome = false,
  });

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

    Widget bodySafeArea = SafeArea(
        child: Row(
      children: [
        if (buildNavigationRail) navigationRailBuilder!(context),
        if (buildNavigationRail) const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: bodyBuilder(context)),
      ],
    ));

    Widget bodyPopScope;
    if (isHome) {
      bodyPopScope = DoubleBackToClose(child: bodySafeArea);
    } else {
      bodyPopScope = PopBackToHome(child: bodySafeArea);
    }

    return Scaffold(
      appBar: appBarBuilder != null ? appBarBuilder!(context) : null,
      drawer: buildDrawer ? SafeArea(child: drawerBuilder!(context)) : null,
      bottomNavigationBar: buildBottomNavigationBar
          ? bottomNavigationBarBuilder!(context)
          : null,
      body: bodyPopScope,
      floatingActionButton: floatingActionButtonBuilder != null
          ? floatingActionButtonBuilder!(context)
          : null,
    );
  }
}
