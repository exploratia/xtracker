import 'package:flutter/material.dart';

import '../../util/theme_utils.dart';

class SingleChildScrollViewWithScrollbar extends StatefulWidget {
  final Widget child;
  final Axis scrollDirection;
  final double Function()? getScrollPosCallback;
  final Future<void> Function()? onRefreshCallback;
  final void Function(ScrollPosition value)? scrollPositionHandler;

  const SingleChildScrollViewWithScrollbar({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.getScrollPosCallback,
    this.onRefreshCallback,
    this.scrollPositionHandler,
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

  void scroll(double position) {
    _scrollController.jumpTo(position);
    // animateTo(20, duration: Duration(seconds: 0), curve: Curves.linear);
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

    final getScrollP = widget.getScrollPosCallback;
    if (getScrollP != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => scroll(getScrollP()));
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
        physics: scrollPhysics,
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        child: Padding(
          padding: ThemeUtils.screenPadding,
          child: child,
        ),
      ),
    );

    if (refreshHandler == null) {
      return scrollbar;
    }

    return RefreshIndicator(onRefresh: refreshHandler, child: scrollbar);
  }
}
