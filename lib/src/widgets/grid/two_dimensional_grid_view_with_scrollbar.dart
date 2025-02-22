import 'package:flutter/material.dart';

import '../../model/series/profile/table_column_profile.dart';
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
  });

  final int lineHeight;
  final TableColumnProfile tableColumnProfile;
  final ValueKey<String> viewportSizeKey;
  final TwoDimensionalChildBuilderDelegate twoDimensionalChildBuilderDelegate;
  final void Function(ScrollPosition value)? verticalScrollPositionHandler;
  final void Function(ScrollPosition value)? horizontalScrollPositionHandler;

  @override
  State<TwoDimensionalGridViewWithScrollbar> createState() => _TwoDimensionalGridViewWithScrollbarState();
}

class _TwoDimensionalGridViewWithScrollbarState extends State<TwoDimensionalGridViewWithScrollbar> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verticalScrollPositionHandler = widget.verticalScrollPositionHandler;
    if (verticalScrollPositionHandler != null) {
      _verticalController.addListener(() {
        verticalScrollPositionHandler(_verticalController.position);
      });
      // Call callback once direct with initial scroll pos (Show Bottom NavBar if not visible)
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
