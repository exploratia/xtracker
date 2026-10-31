import 'package:flutter/material.dart';

import '../../../model/wallpaper_style.dart';
import 'live_wallpaper.dart';
import 'mountain_lake_wallpaper.dart';
import 'river_valley_wallpaper.dart';

/// Renders a motif at a specific time without scheduling animations or updates.
class WallpaperScene extends StatelessWidget {
  const WallpaperScene({super.key, required this.style, required this.percentOfDay});

  final WallpaperStyle style;
  final double percentOfDay;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: switch (style) {
        WallpaperStyle.hills => RepaintBoundary(child: LiveWallpaper(percentOfDay: percentOfDay)),
        WallpaperStyle.mountainLake => MountainLakeWallpaper(percentOfDay: percentOfDay),
        WallpaperStyle.riverValley => RiverValleyWallpaper(percentOfDay: percentOfDay),
      },
    ),
  );
}
