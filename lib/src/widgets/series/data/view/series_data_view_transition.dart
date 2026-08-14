import 'package:flutter/material.dart';

import '../../../../model/series/view_type.dart';

/// Smoothly replaces the data presentation when its view type changes.
class SeriesDataViewTransition extends StatelessWidget {
  const SeriesDataViewTransition({
    super.key,
    required this.viewType,
    required this.child,
  });

  /// Determines the identity of the currently displayed data presentation.
  final ViewType viewType;

  /// Data presentation for [viewType].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(viewType),
        child: child,
      ),
    );
  }
}
