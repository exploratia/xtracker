import 'package:flutter/material.dart';

class AnimateIn extends StatefulWidget {
  final Widget child;
  final int durationMS;
  final bool fade;
  final Offset? slideOffset;

  const AnimateIn({
    super.key,
    required this.child,
    this.durationMS = 2000,
    this.fade = true,
    this.slideOffset,
  });

  @override
  State<AnimateIn> createState() => _AnimateInState();
}

class _AnimateInState extends State<AnimateIn> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: widget.durationMS),
    vsync: this,
  )..forward(); // ..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: widget.slideOffset ?? const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget w = widget.child;

    if (widget.fade) {
      w = FadeTransition(
        opacity: _animation,
        child: w,
      );
    }

    if (widget.slideOffset != null) {
      w = SlideTransition(
        position: _offsetAnimation,
        child: w,
      );
    }

    return w;
  }
}
