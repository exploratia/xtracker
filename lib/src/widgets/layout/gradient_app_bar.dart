import 'package:flutter/material.dart';

class GradientAppBar extends AppBar {
  GradientAppBar(
      {super.key,
      required Widget super.title,
      required List<Color> gradientColors,
      super.foregroundColor,
      super.actions,
      super.actionsIconTheme,
      super.leading,
      super.automaticallyImplyLeading})
      : super(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const AlignmentDirectional(0, 1),
                end: const AlignmentDirectional(0, -0.7),
                colors: gradientColors,
              ),
            ),
          ),
        );

  static GradientAppBar build(BuildContext context,
      {Key? key,
      required Widget title,
      Color? foregroundColor,
      List<Widget>? actions,
      Widget? leading,
      bool automaticallyImplyLeading = true}) {
    final themeData = Theme.of(context);
    List<Color> gradientColors = [
      themeData.colorScheme.primary,
      themeData.colorScheme.secondary,
      themeData.scaffoldBackgroundColor
    ];

    return GradientAppBar(
      title: title,
      gradientColors: gradientColors,
      foregroundColor: themeData.colorScheme.onPrimary,
      actionsIconTheme: IconThemeData(color: themeData.colorScheme.onPrimary),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
    );
  }
}
