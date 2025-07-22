import 'package:flutter/material.dart';

import '../../../model/navigation/navigation.dart';
import '../../../util/navigation/navigation_utils.dart';

class PopBackToHome extends StatelessWidget {
  /// Make Sure this child has a Scaffold widget as parent.
  final Widget child;

  /// Make Sure the child has a Scaffold widget as parent.
  const PopBackToHome({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // is the drawer open? => first close the drawer
        if (NavigationUtils.closeDrawerIfOpen(context)) {
          return;
        }

        Navigation.setCurrentMainNavigationRouteIdx(0, context);
      },
      child: child,
    );
  }
}
