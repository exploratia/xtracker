import 'package:flutter/material.dart';

import '../navigation/hide_bottom_navigation_bar.dart';
import 'single_child_scroll_view_with_scrollbar.dart';

class VCenteredSingleChildScrollViewWithScrollbar extends StatelessWidget {
  const VCenteredSingleChildScrollViewWithScrollbar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) =>
                SingleChildScrollViewWithScrollbar(
              scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
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
