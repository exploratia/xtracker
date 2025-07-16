import 'package:flutter/material.dart';

import '../../util/theme_utils.dart';

class SingleChildScrollViewWithScrollbar extends StatefulWidget {
  final Widget child;
  final Axis scrollDirection;
  final Future<void> Function()? onRefreshCallback;
  final void Function(ScrollPosition value)? scrollPositionHandler;
  final bool useScreenPadding;

  /// [useScreenPadding] set to false if used in widgets which already have padding (e.g. AlertDialog)
  const SingleChildScrollViewWithScrollbar({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.onRefreshCallback,
    this.scrollPositionHandler,
    this.useScreenPadding = true,
  });

  @override
  State<SingleChildScrollViewWithScrollbar> createState() => _SingleChildScrollViewWithScrollbarState();
}

class _SingleChildScrollViewWithScrollbarState extends State<SingleChildScrollViewWithScrollbar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollPositionCb = widget.scrollPositionHandler;
    if (scrollPositionCb != null) {
      _scrollController.addListener(() {
        scrollPositionCb(_scrollController.position);
      });
      // Call callback once direct with initial scroll pos (Show Bottom NavBar if not visible)
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollPositionCb(_scrollController.position));
    }

    final refreshHandler = widget.onRefreshCallback;
    ScrollPhysics? scrollPhysics = (refreshHandler != null) ? const AlwaysScrollableScrollPhysics() : null;

    Widget child;
    if (widget.scrollDirection == Axis.vertical) {
      child = Container(
        // center horizontally
        alignment: Alignment.center,
        child: widget.child,
      );
    } else {
      child = widget.child;
    }

    final scrollbar = Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        padding: widget.useScreenPadding ? ThemeUtils.screenPadding : const EdgeInsets.all(0),
        physics: scrollPhysics,
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        child: child,
      ),
    );

    if (refreshHandler == null) {
      return scrollbar;
    }

    return RefreshIndicator(onRefresh: refreshHandler, child: scrollbar);
  }
}
