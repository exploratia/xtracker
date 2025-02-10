import 'package:flutter/material.dart';

import '../navigation/hide_bottom_navigation_bar.dart';
import 'single_child_scroll_view_with_scrollbar.dart';

class VCenteredSingleChildScrollViewWithScrollbar extends StatelessWidget {
  const VCenteredSingleChildScrollViewWithScrollbar({
    super.key,
    required this.child,
    this.onRefreshCallback,
  });

  final Widget child;
  final Future<void> Function()? onRefreshCallback;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) =>
                SingleChildScrollViewWithScrollbar(
              scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
              onRefreshCallback: onRefreshCallback,
              child: Container(
                constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32) /*-padding*/,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
