import 'package:flutter/material.dart';

import '../../util/media_query_utils.dart';

class DeviceDependentWidthConstrainedBox extends StatelessWidget {
  static const double tabletMaxWidth = 700;
  static const double tabletMinWidth = 500;

  const DeviceDependentWidthConstrainedBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQueryInfo = MediaQueryUtils(MediaQuery.of(context));

    if (mediaQueryInfo.isTablet) {
      return ConstrainedBox(
        // return Container(        color: Colors.red,
        constraints: const BoxConstraints(
          minWidth: tabletMinWidth,
          maxWidth: tabletMaxWidth,
        ),
        child: child,
      );
    }

    return child;
  }
}
