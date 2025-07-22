import 'package:flutter/material.dart';

import '../navigation/nav_back_icon_button.dart';

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

  /// [addLeadingBackBtn] if true and no [leading] is given a back icon
  /// button is added. Hides therefore a possible drawer menu.
  /// Alternative would be a endDrawer.
  static GradientAppBar build(BuildContext context,
      {Key? key,
      required Widget title,
      Color? foregroundColor,
      List<Widget>? actions,
      Widget? leading,
      bool? addLeadingBackBtn,
      bool automaticallyImplyLeading = true}) {
    final themeData = Theme.of(context);
    List<Color> gradientColors = [
      themeData.colorScheme.primary,
      themeData.colorScheme.secondary,
      if (themeData.brightness == Brightness.dark) themeData.scaffoldBackgroundColor,
    ];

    Widget? leadingWidget = leading;
    if (leadingWidget == null && addLeadingBackBtn == true) {
      leadingWidget = const NavBackIconButton();
    }

    return GradientAppBar(
      title: title,
      gradientColors: gradientColors,
      foregroundColor: themeData.colorScheme.onPrimary,
      actionsIconTheme: IconThemeData(color: themeData.colorScheme.onPrimary),
      leading: leadingWidget,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
    );
  }
}
