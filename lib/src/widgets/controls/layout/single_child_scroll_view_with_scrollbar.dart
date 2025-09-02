import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';

class SingleChildScrollViewWithScrollbar extends StatefulWidget {
  final Widget child;
  final Axis scrollDirection;
  final Future<void> Function()? onRefreshCallback;
  final void Function(ScrollPosition value)? scrollPositionHandler;
  final bool useScreenPadding;
  final bool useHorizontalScreenPadding;
  final bool useHorizontalScreenPaddingForScrollbar;

  /// [useScreenPadding] set to false if used in widgets which already have padding (e.g. AlertDialog)
  /// [useHorizontalScreenPadding] set to true if only horizontal padding should be used
  /// [useHorizontalScreenPaddingForScrollbar] set to true if only horizontal padding at scrollbar side should be used
  const SingleChildScrollViewWithScrollbar({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.onRefreshCallback,
    this.scrollPositionHandler,
    this.useScreenPadding = true,
    this.useHorizontalScreenPadding = false,
    this.useHorizontalScreenPaddingForScrollbar = false,
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

    ScrollbarOrientation? orientation;
    EdgeInsetsGeometry padding = const EdgeInsets.all(0);
    if (widget.useScreenPadding) {
      padding = ThemeUtils.screenPaddingAll;
    } else if (widget.useHorizontalScreenPadding) {
      padding = const EdgeInsets.symmetric(horizontal: ThemeUtils.screenPadding);
    } else if (widget.useHorizontalScreenPaddingForScrollbar) {
      // LTR or RTL?
      final textDirection = Directionality.of(context);
      // Scrollbar orientation
      if (textDirection == TextDirection.ltr) {
        orientation = ScrollbarOrientation.right;
        padding = const EdgeInsets.only(right: ThemeUtils.screenPadding);
      } else {
        orientation = ScrollbarOrientation.left;
        padding = const EdgeInsets.only(left: ThemeUtils.screenPadding);
      }
    }

    final scrollbar = Scrollbar(
      controller: _scrollController,
      scrollbarOrientation: orientation,
      child: SingleChildScrollView(
        padding: padding,
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
