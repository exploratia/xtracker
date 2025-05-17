import 'package:flutter/material.dart';

import '../../model/column_profile/column_profile.dart';
import 'two_dimensional_grid_view.dart';

class TwoDimensionalGridViewWithScrollbar extends StatefulWidget {
  const TwoDimensionalGridViewWithScrollbar({
    super.key,
    required this.lineHeight,
    required this.tableColumnProfile,
    required this.viewportSizeKey,
    required this.twoDimensionalChildBuilderDelegate,
    this.verticalScrollPositionHandler,
    this.horizontalScrollPositionHandler,
    this.verticalScrollController,
    this.horizontalScrollController,
  });

  final int lineHeight;
  final ColumnProfile tableColumnProfile;
  final ValueKey<String> viewportSizeKey;
  final TwoDimensionalChildBuilderDelegate twoDimensionalChildBuilderDelegate;
  final void Function(ScrollPosition value)? verticalScrollPositionHandler;
  final void Function(ScrollPosition value)? horizontalScrollPositionHandler;
  final ScrollController? verticalScrollController;
  final ScrollController? horizontalScrollController;

  @override
  State<TwoDimensionalGridViewWithScrollbar> createState() => _TwoDimensionalGridViewWithScrollbarState();
}

class _TwoDimensionalGridViewWithScrollbarState extends State<TwoDimensionalGridViewWithScrollbar> {
  late ScrollController _verticalController;
  late ScrollController _horizontalController;

  @override
  void initState() {
    // ScrollControllers given as parameter?
    _verticalController = widget.verticalScrollController ?? ScrollController();
    _horizontalController = widget.horizontalScrollController ?? ScrollController();

    final verticalScrollPositionHandler = widget.verticalScrollPositionHandler;
    if (verticalScrollPositionHandler != null) {
      _verticalController.addListener(() {
        verticalScrollPositionHandler(_verticalController.position);
      });
      // Call callback once direct with initial scroll pos
      WidgetsBinding.instance.addPostFrameCallback((_) => verticalScrollPositionHandler(_verticalController.position));
    }

    final horizontalScrollPositionHandler = widget.horizontalScrollPositionHandler;
    if (horizontalScrollPositionHandler != null) {
      _horizontalController.addListener(() {
        horizontalScrollPositionHandler(_horizontalController.position);
      });
      // Call callback once direct with initial scroll pos
      WidgetsBinding.instance.addPostFrameCallback((_) => horizontalScrollPositionHandler(_horizontalController.position));
    }

    super.initState();
  }

  @override
  void dispose() {
    // only dispose if not as parameter from parent
    if (widget.verticalScrollController == null) {
      _verticalController.dispose();
    }
    if (widget.horizontalScrollController == null) {
      _horizontalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _verticalController,
      child: Scrollbar(
        controller: _horizontalController,
        notificationPredicate: (notification) => notification.depth == 0, // Ensure it listens only for the main scroll view
        child: TwoDimensionalGridView(
          widget.lineHeight,
          widget.tableColumnProfile,
          // provide a key depending on maxWidth to the ViewPort to force a rebuild if size changes
          widget.viewportSizeKey,
          diagonalDragBehavior: DiagonalDragBehavior.free,
          delegate: widget.twoDimensionalChildBuilderDelegate,
          verticalController: _verticalController,
          horizontalController: _horizontalController,
        ),
      ),
    );
  }
}
