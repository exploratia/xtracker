import 'dart:math';

import 'package:flutter/material.dart';

import '../live_wallpaper/live_wallpaper_refresh.dart';

class Wallpaper extends StatelessWidget {
  final Widget child;
  final bool showWallpaper;

  const Wallpaper({
    super.key,
    required this.child,
    this.showWallpaper = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      // in case of multiple wallpapers - this calculation should be moved static to the wallpaper class
      double wallpaperHeight = min(300, constraints.maxHeight);
      double wallpaperTop = constraints.maxHeight / 2 - wallpaperHeight / 2;
      return Stack(
        children: [
          if (showWallpaper) Positioned.fill(child: Container(color: themeData.scaffoldBackgroundColor)),
          if (showWallpaper) Positioned(top: wallpaperTop, height: wallpaperHeight, left: 0, right: 0, child: const LiveWallpaperRefresh()),
          child,
        ],
      );
    });
  }
}
