import 'package:flutter/cupertino.dart';

import '../../util/media_query_utils.dart';
import 'fab_action_button_data.dart';
import 'fab_radial_expandable.dart';
import 'fab_vertical_expandable.dart';

class FABBuilder {
  static Widget build(
      BuildContext context, List<FabActionButtonData> fabActions) {
    final mediaQueryInfo = MediaQueryUtils(MediaQuery.of(context));
    final isLandscapePhone =
        mediaQueryInfo.isLandscape && !mediaQueryInfo.isTablet;

    if (isLandscapePhone) {
      return FabRadialExpandable(
        distance: 100.0,
        maxAngle: 70,
        startAngle: 10,
        actions: fabActions,
      );
    }
    return FabVerticalExpandable(
      distance: 70.0,
      actions: fabActions,
    );
  }
}
