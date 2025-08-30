import 'package:flutter/material.dart';

import '../../../../generated/assets.gen.dart';
import '../../../model/navigation/navigation.dart';
import '../../../model/navigation/navigation_item.dart';
import '../../../util/media_query_utils.dart';
import '../../../util/theme_utils.dart';
import '../navigation/app_bottom_navigation_bar.dart';
import '../navigation/app_drawer.dart';
import '../navigation/app_navigation_rail.dart';
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

  /// routeName -> HomeScreen ? for double back to close
  final bool isHome;

  /// MainNav ? on tap back goto home
  final bool isMainNavigation;

  const ScreenBuilder({
    super.key,
    required this.bodyBuilder,
    this.appBarBuilder,
    this.floatingActionButtonBuilder,
    this.drawerBuilder,
    this.bottomNavigationBarBuilder,
    this.navigationRailBuilder,
    required this.isHome,
    required this.isMainNavigation,
  });

  /// ShortHand constructor for standard navigation
  /// [isHome] and [isMainNavigation] are determined by routeName
  ScreenBuilder.withStandardNavBuilders({
    Key? key,
    PreferredSizeWidget Function(BuildContext context)? appBarBuilder,
    required Widget Function(BuildContext context) bodyBuilder,
    Widget Function(BuildContext context)? floatingActionButtonBuilder,
    required NavigationItem navItem,
  }) : this(
            key: key,
            appBarBuilder: appBarBuilder,
            bodyBuilder: bodyBuilder,
            floatingActionButtonBuilder: floatingActionButtonBuilder,
            isHome: navItem.routeName == '/',
            isMainNavigation: Navigation.containsMainNavigationRoute(navItem.routeName),
            drawerBuilder: (context) => const AppDrawer(),
            navigationRailBuilder: (context) => const AppNavigationRail(),
            bottomNavigationBarBuilder: (context) => const AppBottomNavigationBar());

  @override
  Widget build(BuildContext context) {
    final mediaQueryInfo = MediaQueryUtils.of(context);

    if (mediaQueryInfo.isSmallScreen) {
      return const _TooSmallScreen();
    }

    final buildBottomNavigationBar = bottomNavigationBarBuilder != null && mediaQueryInfo.isPortrait;
    final buildNavigationRail =
        !buildBottomNavigationBar && navigationRailBuilder != null && (mediaQueryInfo.isLandscape && mediaQueryInfo.mediaQueryData.size.width > 600);
    final buildDrawer = !buildBottomNavigationBar && !buildNavigationRail && drawerBuilder != null;

    Widget bodySafeArea = SafeArea(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (buildNavigationRail) navigationRailBuilder!(context),
        if (buildNavigationRail) const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: bodyBuilder(context)),
      ],
    ));

    // PopScope depending on nav
    Widget bodyPopScope;
    if (isHome) {
      bodyPopScope = DoubleBackToClose(child: bodySafeArea);
    } else if (isMainNavigation) {
      bodyPopScope = PopBackToHome(child: bodySafeArea);
    } else {
      bodyPopScope = bodySafeArea;
    }

    return Scaffold(
      appBar: appBarBuilder != null ? appBarBuilder!(context) : null,
      drawer: buildDrawer ? SafeArea(child: drawerBuilder!(context)) : null,
      bottomNavigationBar: buildBottomNavigationBar ? bottomNavigationBarBuilder!(context) : null,
      body: bodyPopScope,
      floatingActionButton: floatingActionButtonBuilder != null ? floatingActionButtonBuilder!(context) : null,
    );
  }
}

class _TooSmallScreen extends StatelessWidget {
  const _TooSmallScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: ThemeUtils.verticalSpacing,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: ThemeUtils.verticalSpacing),
                SizedBox(
                  height: 32,
                  width: 32,
                  child: Assets.images.logos.appLogo.image(fit: BoxFit.cover),
                ),
                const Text("App is not designed for screens < 250x300."),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
