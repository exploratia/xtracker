import 'package:flutter/material.dart';

/// Fades and vertically expands or collapses [child] without measuring its
/// changing size during render layout.
class AnimatedExpansion extends StatefulWidget {
  const AnimatedExpansion({
    super.key,
    required this.expanded,
    required this.duration,
    required this.child,
  });

  /// Whether [child] is fully visible.
  final bool expanded;

  /// Duration of the transition.
  final Duration duration;

  /// Content being expanded or collapsed.
  final Widget child;

  @override
  State<AnimatedExpansion> createState() => _AnimatedExpansionState();
}

class _AnimatedExpansionState extends State<AnimatedExpansion> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    value: widget.expanded ? 1 : 0,
    duration: widget.duration,
    vsync: this,
  );

  @override
  void didUpdateWidget(covariant AnimatedExpansion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (widget.duration == Duration.zero) {
      _controller.value = widget.expanded ? 1 : 0;
    } else if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SizeTransition(
        sizeFactor: _controller,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: double.infinity,
          child: widget.child,
        ),
      ),
    );
  }
}
