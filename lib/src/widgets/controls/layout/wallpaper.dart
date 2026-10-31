import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/wallpaper_style.dart';
import '../../administration/settings/settings_controller.dart';
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
    final style = context.select<SettingsController?, WallpaperStyle>((settings) => settings?.wallpaperStyle ?? WallpaperStyle.hills);
    return LayoutBuilder(
      builder: (context, constraints) {
        final centered = style == WallpaperStyle.hills;
        final wallpaperHeight = min(300.0, constraints.maxHeight);
        double wallpaperTop = constraints.maxHeight / 2 - wallpaperHeight / 2;
        return Stack(
          children: [
            if (showWallpaper) Positioned.fill(child: Container(color: themeData.scaffoldBackgroundColor)),
            if (showWallpaper)
              Positioned(
                top: centered ? wallpaperTop : 0,
                bottom: centered ? null : 0,
                height: centered ? wallpaperHeight : null,
                left: 0,
                right: 0,
                child: LiveWallpaperRefresh(style: style),
              ),
            child,
          ],
        );
      },
    );
  }
}
