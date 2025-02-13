import 'package:flutter/material.dart';

import 'device_layout_builder.dart';

class DeviceDependentWidthConstrainedBox extends StatelessWidget {
  static const double tabletMaxWidth = 700;
  static const double tabletMinWidth = 500;

  const DeviceDependentWidthConstrainedBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DeviceLayoutBuilder(
      phoneBuilder: (context) => child,
      tabletBuilder: (context) => ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: tabletMinWidth,
          maxWidth: tabletMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
