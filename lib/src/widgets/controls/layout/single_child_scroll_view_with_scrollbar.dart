import 'package:material_ui/material_ui.dart';

import '../../../util/theme_utils.dart';

class SingleChildScrollViewWithScrollbar extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final Axis scrollDirection;
  final Future<void> Function()? onRefreshCallback;
  final void Function(ScrollPosition value)? scrollPositionHandler;
  final bool useScreenPadding;
  final bool useHorizontalScreenPadding;
  final bool useHorizontalScreenPaddingForScrollbar;

  /// [useScreenPadding] set to true if screen padding should be used
  /// [useHorizontalScreenPadding] set to true if only horizontal padding should be used
  /// [useHorizontalScreenPaddingForScrollbar] set to true if only horizontal padding at scrollbar side should be used
  const SingleChildScrollViewWithScrollbar({
    super.key,
    required this.child,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.onRefreshCallback,
    this.scrollPositionHandler,
    this.useScreenPadding = false,
    this.useHorizontalScreenPadding = false,
    this.useHorizontalScreenPaddingForScrollbar = false,
  });

  @override
  State<SingleChildScrollViewWithScrollbar> createState() => _SingleChildScrollViewWithScrollbarState();
}

class _SingleChildScrollViewWithScrollbarState extends State<SingleChildScrollViewWithScrollbar> {
  late final ScrollController _scrollController;
  late final bool _ownsController;
  VoidCallback? _scrollListener;

  @override
  void initState() {
    super.initState();

    _ownsController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();

    final cb = widget.scrollPositionHandler;
    if (cb != null) {
      _scrollListener = () {
        cb(_scrollController.position);
      };
      _scrollController.addListener(_scrollListener!);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        cb(_scrollController.position);
      });
    }
  }

  @override
  void dispose() {
    final scrollListener = _scrollListener;
    if (scrollListener != null) {
      _scrollController.removeListener(scrollListener);
      _scrollListener = null;
    }

    if (_ownsController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    ScrollPhysics? scrollPhysics = widget.onRefreshCallback != null ? const AlwaysScrollableScrollPhysics() : null;

    Widget child = widget.scrollDirection == Axis.vertical ? Align(alignment: Alignment.center, child: widget.child) : widget.child;

    ScrollbarOrientation? orientation;
    EdgeInsetsGeometry padding = EdgeInsets.zero;

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

    return widget.onRefreshCallback == null
        ? scrollbar
        : RefreshIndicator(
            onRefresh: widget.onRefreshCallback!,
            child: scrollbar,
          );
  }
}
