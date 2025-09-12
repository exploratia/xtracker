import 'package:flutter/material.dart';

import '../../../util/chart/chart_utils.dart';
import '../../../util/color_utils.dart';

class LiveWallpaperHills {
  static List<Widget> buildHills(double height, double width, num sceneDim, Color baseColor) {
    return [
      ..._buildHill(
        bottom: height / 3 - sceneDim / 30,
        left: width / 2 - sceneDim / 2,
        width: sceneDim / 6,
        height: sceneDim / 10,
        baseColor: ColorUtils.darken(baseColor, 10),
        rightLight: 0.7,
      ),
      ..._buildHill(
        bottom: height / 3 - sceneDim / 27,
        left: width / 2 - sceneDim / 2.2,
        width: sceneDim / 7,
        height: sceneDim / 12,
        baseColor: ColorUtils.darken(baseColor, 10),
        rightLight: 0.7,
      ),
      ..._buildHill(
        bottom: height / 3 - sceneDim / 30,
        right: width / 2 - sceneDim / 3,
        width: sceneDim / 5,
        height: sceneDim / 7,
        baseColor: ColorUtils.darken(baseColor, 10),
        leftLight: 0.3,
      ),
      ..._buildHill(
        bottom: height / 3 - sceneDim / 26,
        right: width / 2 - sceneDim / 2.1,
        width: sceneDim / 3.5,
        height: sceneDim / 13,
        baseColor: ColorUtils.darken(baseColor, 10),
        leftLight: 0.3,
      ),
      ..._buildHill(
        bottom: height / 3 - sceneDim / 23,
        right: width / 2 - sceneDim / 2.9,
        width: sceneDim / 5,
        height: sceneDim / 19,
        baseColor: ColorUtils.darken(baseColor, 10),
        leftLight: 0.3,
      ),
    ];
  }

  static List<Widget> _buildHill({
    required double bottom,
    required double width,
    required double height,
    required Color baseColor,
    double? left,
    double? right,
    double? rightLight,
    double? leftLight,
  }) {
    if (right == null && left == null || left != null && right != null) return [];

    List<Widget> list = [
      Positioned(
        bottom: bottom,
        left: left,
        right: right,
        width: width,
        height: height,
        child: ClipPath(
          clipper: _TriangleClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: ChartUtils.createBottomToTopGradient(
                [baseColor, ColorUtils.lighten(baseColor, 30)],
              ),
            ),
          ),
        ),
      ),
    ];

    if (rightLight != null && rightLight > 0 && rightLight < 1) {
      list.add(Positioned(
        bottom: bottom,
        left: left,
        right: right,
        width: width,
        height: height,
        child: ClipPath(
          clipper: _TriangleClipper(bottomLeft: rightLight),
          child: Container(
            decoration: BoxDecoration(
              gradient: ChartUtils.createBottomToTopGradient(
                [baseColor, ColorUtils.lighten(baseColor, 50)],
              ),
            ),
          ),
        ),
      ));
    }
    if (leftLight != null && leftLight > 0 && leftLight < 1) {
      list.add(Positioned(
        bottom: bottom,
        left: left,
        right: right,
        width: width,
        height: height,
        child: ClipPath(
          clipper: _TriangleClipper(bottomRight: leftLight),
          child: Container(
            decoration: BoxDecoration(
              gradient: ChartUtils.createBottomToTopGradient(
                [baseColor, ColorUtils.lighten(baseColor, 50)],
              ),
            ),
          ),
        ),
      ));
    }

    return list;
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  final double bottomLeft;
  final double bottomRight;

  _TriangleClipper({this.bottomLeft = 0, this.bottomRight = 1});

  @override
  Path getClip(Size size) {
    Path path = Path(); // Create a Path object to draw the shape.

    // Draw the triangle:
    path.moveTo(size.width * bottomLeft, size.height);
    path.lineTo(size.width * bottomRight, size.height);
    path.lineTo(size.width / 2, 0);
    path.close();

    return path; // Return the completed shape.
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // No need to redraw the shape unless it changes.
  }
}
