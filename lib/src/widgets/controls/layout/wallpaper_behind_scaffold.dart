import 'dart:math';

import 'package:flutter/material.dart';

import '../live_wallpaper/live_wallpaper_refresh.dart';

class WallpaperBehindScaffold extends StatelessWidget {
  final Scaffold scaffold;

  const WallpaperBehindScaffold({super.key, required this.scaffold});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      double wallpaperHeight = min(300, constraints.maxHeight);
      double wallpaperTop = constraints.maxHeight / 2 - wallpaperHeight / 2;
      return Stack(
        children: [
          Positioned.fill(child: Container(color: themeData.scaffoldBackgroundColor)),
          Positioned(top: wallpaperTop, height: wallpaperHeight, left: 0, right: 0, child: const LiveWallpaperRefresh()),
          scaffold,
        ],
      );
    });
  }
}
