import 'package:flutter/material.dart';

/// Fades and slightly slides the date filter without discarding its state.
class SeriesDataFilterTransition extends StatefulWidget {
  const SeriesDataFilterTransition({
    super.key,
    required this.visible,
    required this.onHidden,
    required this.child,
  });

  /// Whether the filter should be visible and interactive.
  final bool visible;

  /// Called after the filter has fully finished hiding.
  final VoidCallback onHidden;

  /// Date-filter content whose state is preserved while hidden.
  final Widget child;

  @override
  State<SeriesDataFilterTransition> createState() => _SeriesDataFilterTransitionState();
}

class _SeriesDataFilterTransitionState extends State<SeriesDataFilterTransition> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    value: widget.visible ? 1 : 0,
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(_animation);

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_handleAnimationStatus);
  }

  @override
  void didUpdateWidget(covariant SeriesDataFilterTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) {
      return;
    }
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.visible) {
      widget.onHidden();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.visible,
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
