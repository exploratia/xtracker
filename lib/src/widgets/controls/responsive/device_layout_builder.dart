import 'package:flutter/material.dart';

import '../../../util/media_query_utils.dart';

class DeviceLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context)? tabletBuilder;
  final Widget Function(BuildContext context) phoneBuilder;

  const DeviceLayoutBuilder({super.key, this.tabletBuilder, required this.phoneBuilder});

  @override
  Widget build(BuildContext context) {
    final mediaQueryInfo = MediaQueryUtils.of(context);
    if (mediaQueryInfo.isTablet && tabletBuilder != null) {
      return tabletBuilder!(context);
    }

    return phoneBuilder(context);
  }
}
