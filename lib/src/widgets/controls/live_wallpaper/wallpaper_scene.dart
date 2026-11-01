import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../model/wallpaper_style.dart';
import '../../../util/wallpaper/wallpaper_image_lighting.dart';
import '../layout/wallpaper_image.dart';
import 'live_wallpaper.dart';
import 'mountain_lake_wallpaper.dart';
import 'moonlit_horizon_wallpaper.dart';
import 'river_valley_wallpaper.dart';

/// Renders a motif at a specific time without scheduling animations or updates.
class WallpaperScene extends StatelessWidget {
  const WallpaperScene({
    super.key,
    required this.style,
    required this.percentOfDay,
    this.image,
    this.imageLighting = const WallpaperImageLighting(luminance: 0),
  });

  final WallpaperStyle style;
  final double percentOfDay;

  /// Selected photo for the custom motif; a missing photo uses the hills fallback.
  final Uint8List? image;

  /// Previously sampled lighting for [image], shared with the settings preview.
  final WallpaperImageLighting imageLighting;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: switch (style) {
        WallpaperStyle.customImage when image != null => WallpaperImage(bytes: image!, percentOfDay: percentOfDay, lighting: imageLighting),
        WallpaperStyle.hills || WallpaperStyle.customImage => RepaintBoundary(child: LiveWallpaper(percentOfDay: percentOfDay)),
        WallpaperStyle.mountainLake => MountainLakeWallpaper(percentOfDay: percentOfDay),
        WallpaperStyle.riverValley => RiverValleyWallpaper(percentOfDay: percentOfDay),
        WallpaperStyle.moonlitHorizon => MoonlitHorizonWallpaper(percentOfDay: percentOfDay),
      },
    ),
  );
}
