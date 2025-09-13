import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../util/chart/chart_utils.dart';
import '../../../util/theme_utils.dart';
import 'live_wallpaper_hills.dart';
import 'live_wallpaper_starry_sky.dart';

class LiveWallpaper extends StatelessWidget {
  final double percentOfDay;

  const LiveWallpaper({
    super.key,
    this.percentOfDay = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final minDim = math.min(width, height);
        final sceneDim = math.min(300.0, minDim);

        var t2 = 1 - ((percentOfDay - 0.5) * 2).abs();
        Color skyColor = Color.lerp(const Color.fromRGBO(1, 6, 53, 1), ThemeUtils.primary, t2) ?? ThemeUtils.primary;
        Color groundColor = Color.lerp(const Color.fromRGBO(51, 21, 74, 1), ThemeUtils.secondary, t2) ?? ThemeUtils.secondary;

        List<Widget>? fadeOuts = [];
        if (width > sceneDim) {
          var fadeWidth = (width - sceneDim) / 2;
          var fadeOutColors = [
            themeData.scaffoldBackgroundColor,
            themeData.scaffoldBackgroundColor.withAlpha(0),
          ];
          fadeOuts = [
            _buildFadeOut(fadeWidth, fadeOutColors, left: 0),
            _buildFadeOut(fadeWidth, fadeOutColors, right: 0),
          ];
        }

        return Stack(
          children: [
            // heaven
            Positioned(
              top: 0,
              bottom: height / 3,
              left: 1,
              right: 1,
              child: Container(
                decoration: BoxDecoration(gradient: ChartUtils.createBottomToTopGradient([skyColor, themeData.scaffoldBackgroundColor])),
              ),
            ),
            Positioned(
              top: 0,
              bottom: (height / 3).truncateToDouble() - 1,
              left: 1,
              right: 1,
              child: Opacity(
                  opacity: 1 - t2,
                  child: LiveWallpaperStarrySky(
                    seed: 2,
                    density: 0.0005 * ((math.sin(1.65 * math.cos(2 * math.pi * percentOfDay)) + 1) / 2),
                  )),
            ),
            // sun & moon
            _buildSunAndMoon(height, width, sceneDim, percentOfDay),
            // ground
            Positioned(
              top: (height * 2 / 3).truncateToDouble() - 1,
              left: 1,
              right: 0,
              bottom: -1,
              child: Container(
                decoration: BoxDecoration(gradient: ChartUtils.createTopToBottomGradient([groundColor, themeData.scaffoldBackgroundColor])),
              ),
            ),
            // hills
            ...LiveWallpaperHills.buildHills(height, width, sceneDim, groundColor),
            // fade out left/right
            ...fadeOuts,
          ],
        );
      },
    );
  }

  Positioned _buildSunAndMoon(double height, double width, double sceneDim, double percentOfDay) {
    return Positioned(
      height: sceneDim,
      bottom: (height / 3 - sceneDim / 2),
      left: width / 2 - sceneDim / 2,
      width: sceneDim,
      child: Transform.rotate(
        angle: math.pi * 2 * percentOfDay,
        child: ClipOval(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Moon
              _buildSkyBody(
                sceneDim,
                [const Color.fromRGBO(214, 230, 255, 0.4), const Color.fromRGBO(138, 168, 214, 0)],
                [Colors.white, const Color.fromRGBO(214, 230, 255, 1), const Color.fromRGBO(138, 168, 214, 1)],
              ),
              // Sun
              _buildSkyBody(
                sceneDim,
                [const Color.fromRGBO(255, 217, 61, 0.5), const Color.fromRGBO(255, 140, 66, 0)],
                [const Color.fromRGBO(255, 247, 161, 1), const Color.fromRGBO(255, 217, 61, 1), const Color.fromRGBO(255, 140, 66, 1)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildSkyBody(double sceneDim, List<Color> glow, List<Color> body) {
    return Container(
      width: sceneDim / 3,
      height: sceneDim / 3,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: glow,
        ),
      ),
      child: Center(
        child: ClipOval(
          child: Container(
            width: sceneDim / 8,
            height: sceneDim / 8,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: body,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Positioned _buildFadeOut(double fadeWidth, List<Color> colors, {double? left, double? right}) {
    return Positioned(
      top: 0,
      width: fadeWidth,
      right: right,
      left: left,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: ChartUtils.createLeftToRightGradient(
            right != null ? colors.reversed.toList() : colors,
          ),
        ),
      ),
    );
  }
}
