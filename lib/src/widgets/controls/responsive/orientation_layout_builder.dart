import 'package:flutter/material.dart';

import '../../../util/media_query_utils.dart';

class OrientationLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context)? landscapeBuilder;
  final Widget Function(BuildContext context)? portraitBuilder;

  const OrientationLayoutBuilder({super.key, this.landscapeBuilder, this.portraitBuilder});

  @override
  Widget build(BuildContext context) {
    // only one builder set?
    if (landscapeBuilder == null && portraitBuilder != null) {
      return portraitBuilder!(context);
    }
    if (landscapeBuilder != null && portraitBuilder == null) {
      return landscapeBuilder!(context);
    }

    final orientation = MediaQueryUtils.of(context).orientation;
    if (orientation == Orientation.landscape && landscapeBuilder != null) {
      return landscapeBuilder!(context);
    }
    if (orientation == Orientation.portrait && portraitBuilder != null) {
      return portraitBuilder!(context);
    }
    return const Placeholder();
  }
}
