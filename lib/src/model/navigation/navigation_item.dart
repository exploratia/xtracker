import 'package:flutter/material.dart';

import '../../util/theme_utils.dart';

class NavigationItem {
  final IconData iconData;
  final String routeName;
  final String Function() titleBuilder;

  NavigationItem({
    required this.iconData,
    required this.routeName,
    required this.titleBuilder,
  });

  Icon icon({double? size}) {
    return Icon(
      iconData,
      size: size ?? ThemeUtils.iconSizeScaled,
    );
  }
}
