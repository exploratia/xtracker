import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';
import 'single_child_scroll_view_with_scrollbar.dart';

class VCenteredSingleChildScrollViewWithScrollbar extends StatelessWidget {
  const VCenteredSingleChildScrollViewWithScrollbar({
    super.key,
    required this.child,
    this.onRefreshCallback,
    this.scrollPositionHandler,
  });

  final Widget child;
  final Future<void> Function()? onRefreshCallback;
  final void Function(ScrollPosition value)? scrollPositionHandler;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollViewWithScrollbar(
              useScreenPadding: true,
              scrollPositionHandler: scrollPositionHandler,
              onRefreshCallback: onRefreshCallback,
              child: Container(
                constraints: BoxConstraints(minHeight: math.max(20, constraints.maxHeight - 2 * ThemeUtils.screenPadding)),
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
