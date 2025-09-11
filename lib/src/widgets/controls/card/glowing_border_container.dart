import 'package:flutter/material.dart';

class GlowingBorderContainer extends StatelessWidget {
  // final double width;
  // final double height;
  final Widget child;
  final Color glowColor;
  final double borderWidth;
  final double blurRadius;

  const GlowingBorderContainer({
    super.key,
    required this.child,
    // this.width = 200,
    // this.height = 100,
    this.glowColor = Colors.blue,
    this.borderWidth = 2.0,
    this.blurRadius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      // width: width,
      // height: height,
      margin: EdgeInsets.all(blurRadius),
      decoration: createGlowingBoxDecoration(
        glowColor,
        (themeData.brightness == Brightness.dark) ? themeData.scaffoldBackgroundColor : themeData.cardTheme.color,
        borderWidth: borderWidth,
        blurRadius: blurRadius,
      ),
      child: Center(child: child),
    );
  }

  static BoxDecoration createGlowingBoxDecoration(
    Color glowColor,
    Color? backgroundColor, {
    double borderRadius = 12,
    double borderWidth = 2,
    double blurRadius = 10,
  }) {
    return BoxDecoration(
      color: backgroundColor, // Inner background color
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: glowColor, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.8), // Glow effect
          blurRadius: blurRadius,
          spreadRadius: borderWidth, // Intensity of the glow
        ),
      ],
    );
  }
}
